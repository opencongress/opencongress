class AccountController < ApplicationController
  before_filter :login_from_cookie, :except => [:reset_password]
  before_filter :login_required, :only => [:welcome, :accept_tos]
  after_filter :check_wiki, :only => [:login, :activate]

  skip_before_filter :store_location
  skip_before_filter :has_accepted_tos?, :only => [:accept_tos, :logout]
  skip_before_filter :is_banned?, :only => [:logout]
  include OpenIdAuthentication

#  observer :user_observer

  def index
    unless logged_in?
      redirect_to(login_path)
    else
      redirect_to(user_profile_path(:login => current_user.login))
    end
  end

  def get_user_email
    if params[:id] == ApiKeys.wiki_callback_key
      user = User.find(:first, :conditions => ["lower(login) = ?", params[:login].downcase])
      render :text => "#{user.email}"
    else
      redirect_to :action => :index
    end
  end

  def get_user_full_name
    if params[:id] == ApiKeys.wiki_callback_key
      user = User.find(:first, :conditions => ["lower(login) = ?", params[:login].downcase])
      render :text => "#{user.full_name}"
    else
      redirect_to :action => :index
    end
  end

  def login    
    if params[:login_action]
      session[:login_action] = {:url => session[:return_to], :action_result => params[:login_action]}
    end

    # Forum Integration
    if params[:modal]
      render :action => 'login_modal', :layout => false
    end

    if params[:ReturnUrl]
      session[:return_to] = params[:ReturnUrl]
    end

    if params[:wiki_return_page]
      session[:return_to] = "#{Settings.wiki_base_url}/#{params[:wiki_return_page]}"
    end

    # if the return_to is nil at this point, try setting it with the referrer
    if session[:return_to].nil?
      session[:return_to] = request.referer
    end
    
    if using_open_id?
       open_id_authentication(params[:openid_url])
    elsif params[:user]
      self.current_user = User.authenticate(params[:user][:login], params[:user][:password])
      return unless request.post?
    else
      return unless request.post?
    end

    if logged_in?
      self.current_user.update_attribute(:previous_login_date, self.current_user.last_login ? self.current_user.last_login : Time.now)
      self.current_user.update_attribute(:last_login, Time.now)
      ip = self.current_user.user_ip_addresses.find_or_create_by_addr(UserIpAddress.int_form(request.remote_ip))
      self.current_user.check_feed_key
      process_login_actions
      cookies[:ocloggedin]="true"
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      if self.current_user.fans.find(:first, :conditions => ["confirmed = ? AND created_at > ?", false, self.current_user.previous_login_date])
        flash[:notice] = "Logged in * " + "<a href='#{url_for(:controller => 'friends', :login => self.current_user.login)}'>New Friends Requests!</a> *"
      else
        flash[:notice] = "Logged in successfully"
      end
      redirect_back_or_default(user_profile_url(current_user.login))
    else
      flash.now[:warning] = "Login failed"
    end
  end
  
  def accept_tos
    @page_title = "Please Accept our Terms of Service and Privacy Policy"
    if request.post?
      user = User.find_by_id(current_user.id)
      if params[:accept_tos] == "1"
        user.accepted_tos = true
        user.accepted_tos_at = Time.now
        user.save!
        self.current_user = User.find_by_id(user.id)
        redirect_back_or_default(user_profile_path(:login => current_user.login))
      end
    end
  end

  def determine_district
    @page_title = "Determine Your Congressional District"
    
    if request.post?
      yg = YahooGeocoder.new("#{params[:address]}, #{current_user.zipcode}")
      unless yg.zip4.nil?
        current_user.zip_four = yg.zip4
        current_user.save
        
        current_user.join_default_groups
        
        flash[:notice] = "Your Congressional District (#{current_user.district}) has been saved."
        redirect_to(user_profile_path(:login => current_user.login))
      else
        @error_msg = "Sorry, that address in zip code #{current_user.zipcode} was not recognized.  Please try again.  If you keep receiving this error, please send an email to writeus@opencongress.org"
      end
    end
  end
  
  def facebook_complete
    @page_title = 'Facebook Connect'
    
    @user = User.where(['facebook_uid=?', @facebook_user.id]).first
    if @user.nil?
      @user = User.new
    end
    
    if request.post?
      @user.update_attributes(params[:user])
      @user.facebook_uid = @facebook_user.id
      @user.email = @facebook_user.email
      
      if @user.save
        @user.activate
        self.current_user = @user
        flash[:notice] = 'You have successfully signed up with your Facebook Account!'
        
        redirect_to welcome_url
        return
      end
    end
  end
  
  def contact_congress
    @page_title = 'Contact Congress'
    
    if session[:formageddon_unsent_threads].nil?
      # not sure how we got here; redirect to regular signup
      redirect_to '/signup'
      return
    end
    
    thread = Formageddon::FormageddonThread.find(session[:formageddon_unsent_threads].first)
    if thread.nil?
      # not sure how we got here; redirect to regular signup
      redirect_to '/signup'
      return
    end

    # first see if we recognize the email address
    @existing_user = User.where(["UPPER(email)=?", thread.sender_email.upcase]).first
    unless @existing_user
      @new_user = User.new   
      @new_user.email = thread.sender_email
      @new_user.zipcode = thread.sender_zip5
      @new_user.zip_four = thread.sender_zip4
      puts "setting zip_four to #{thread.sender_zip4}"
    end
    
    if request.post?
      @new_user.update_attributes(params[:user])
      
      if @new_user.save
        redirect_to(:controller => 'account', :action => 'confirm', :login => @new_user.login)
        
        return
      end
    end
  end
  
  def group_signup_complete
    if request.post?
      @group_invite = GroupInvite.find(params[:group_invite_id])
      @user = User.new(params[:user])
      
      if @user.email != @group_invite.email
        redirect_to groups_path, :error => 'There was an error with the group invitation.'
        return
      end
      
      @group = @group_invite.group
      
      if @user.save
        @user.activate
        self.current_user = @user
        
        @group_invite.user = @user
        @group_invite.save
        
        redirect_to group_group_invite_path(@group, @group_invite, :key => @group_invite.key)
      else
        render :action => 'group_invites/show'
      end
    end
  end
  
  def signup
    @page_title = "Create a New Account"

    @user = User.new(params[:user])
    @user.email = session[:invite].invitee_email unless session[:invite].nil? or request.post?

    return unless request.post?

    @user.accepted_tos = true
    @user.accepted_tos_at = Time.now

    if @user.zipcode
      @senators, @reps = Person.find_current_congresspeople_by_zipcode(@user.zipcode, @user.zip_four)
      @user.representative_id = @reps.first.id if (@reps && @reps.length == 1)
    end  

    if @user.save
      # check for an invitation
      if session[:invite]
        Friend.create_confirmed_friendship(@user, session[:invite].inviter)
        session[:invite] = nil
      end

      @user.join_default_groups
      
      redirect_to(:controller => 'account', :action => 'confirm', :login => @user.login)
    else
      render :action => 'signup'
    end
  end

  def confirm
    @page_title = 'Confirm Your Email Address'
    
    @user = User.find_by_login(params[:login], :conditions => ["activated_at is null"])

    @contact_congress_signup = session[:formageddon_unsent_threads].nil? ? false : true
  end

  def logout
    if params[:wiki_return_page]
      session[:return_to] = "http://www.opencongress.org/wiki/#{params[:wiki_return_page]}"
    end    
    redirect_loc = session[:return_to]
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    cookies.delete '_session_id'
    cookies.delete 'ocloggedin'
    cookies['PHPSESSID'] = {:value => '', :path => '/', :expires => Time.at(0), :domain => ".www.opencongress.org" }
    cookies['PHPSESSID'] = {:value => '', :path => '/', :expires => Time.at(0), :domain => ".opencongress.org" }
    cookies['PHPSESSID'] = {:value => '', :path => '/', :expires => Time.at(0), :domain => ".www.opencongress.org" }
    cookies.delete 'wikiToken', {:domain => '.opencongress.org'}
    cookies.delete 'wiki_session', {:domain => '.opencongress.org'}
    cookies.delete 'wikiUserID', {:domain => '.opencongress.org'}
    cookies.delete 'wikiUserName', {:domain => '.opencongress.org'}
    
    # force hard delete of the facebook cookie
    cookies.delete fb_cookie_name
    
    reset_session
    session[:return_to] = redirect_loc
    flash[:notice] = "You have been logged out."
    
    #redirect_back_or_default('/')
    redirect_to :controller => 'index'
  end
  
  def activate
    @page_title = 'Account Activation'
    
    @user = User.find_by_activation_code(params[:id])
    if @user and @user.activate
      self.current_user = @user
      
      if session[:formageddon_unsent_threads].nil?
        redirect_to welcome_url
        return
      else
        redirect_to '/contact_congress_letters/delayed_send'
        return
      end
    else
      flash[:notice] = "We didn't find that confirmation code; maybe you've already activated your account?"
      redirect_to signup_url
      return
    end
  end

  def welcome
    @page_title = 'Welcome to OpenCongress!'
    @user = current_user
    @show_tracked_list = true

    @most_viewed_bills = ObjectAggregate.popular('Bill', Settings.default_count_time, 5)
    @senators, @reps = Person.find_current_congresspeople_by_zipcode(@user.zipcode, @user.zip_four) if ( logged_in? && @user == current_user && !(@user.zipcode.nil? || @user.zipcode.empty?))
  end

  def forgot_password
    return unless request.post?
    if !params[:user][:email].blank? and (@user = User.find(:first, :conditions => ["UPPER(email) = ?", params[:user][:email].upcase]))
      @user.forgot_password
      @user.save!
      # redirect_back_or_default(:controller => 'account', :action => 'index')
      @page_title = "Forgot Password"
      render :action => 'pwmail'
    else
      flash.now[:notice] = "Could not find a user with that email address."
    end
  end

  def reset_password
    redirect_to '/account/forgot_password' and return if params[:id].blank?
    @user = User.find_by_password_reset_code(params[:id])
    @page_title = "Reset Password"
    
    if @user.nil?
      flash[:error] = "Password reset link not recognized.  Please try again."
      redirect_to '/account/forgot_password'
    else
      return unless request.post?
    
      @user.password = ''
    end
    
    if (params[:user][:password] == params[:user][:password_confirmation])
      self.current_user = @user #for the next two lines to work
      current_user.password_confirmation = params[:user][:password_confirmation]
      current_user.password = params[:user][:password]
      @user.reset_password
      flash[:notice] = current_user.save ? "Password reset" : "Password not reset"
    else
      flash[:notice] = "Password mismatch"
    end
    redirect_back_or_default(:controller => 'account', :action => 'index')
  end

  def profile
    @user = User.find_by_login(params[:user])
  end
  def change_pw
    @user = current_user
    if (params[:user][:password] == params[:user][:password_confirmation])
      self.current_user = @user #for the next two lines to work
      current_user.password_confirmation = params[:user][:password_confirmation]
      current_user.password = params[:user][:password]
      @user.reset_password
      flash[:notice] = current_user.save ? "Password reset" : "Password not reset"
    else
      flash[:notice] = "Password mismatch"
    end
    redirect_back_or_default(user_profile_path(:login => current_user.login))
  end

  def mailing_list
   if params[:user][:mailing] && params[:user][:mailing] == "1"
     current_user.mailing = true
     flash[:notice] = "Subscribed to the Mailing List"
   else
     current_user.mailing = false
     flash[:notice] = "Un-Subscribed from the Mailing List"
   end
   current_user.save!
   redirect_back_or_default(user_profile_path(:login => current_user.login))
  end

  def partner_mailing_list
   if params[:user][:partner_mailing] && params[:user][:partner_mailing] == "1"
     current_user.partner_mailing = true
     flash[:notice] = "Subscribed to the Mailing List"
   else
     current_user.partner_mailing = false
     flash[:notice] = "Un-Subscribed from the Mailing List"
   end
   current_user.save!
   redirect_back_or_default(user_profile_path(:login => current_user.login))
  end


  def why
  end

  def invited
    invite = FriendInvite.find_by_invite_key(params[:id])
    
    session[:invite] = invite
    
    redirect_to signup_url
  end

  def new_openid
   @page_title = "New OpenID Account"
   identity_url = session[:idurl]
   if request.post? && identity_url
     begin
       @user = User.new(params[:user])
       @user.identity_url = identity_url
       @user.email = session[:invite].invitee_email unless session[:invite].nil? or request.post?
  
       @user.accepted_tos = true
       @user.accepted_tos_at = Time.now     
  
       if @user.zipcode
         @senators, @reps = Person.find_current_congresspeople_by_zipcode(@user.zipcode, @user.zip_four)
         @user.representative_id = @reps.first.id if (@reps && @reps.length == 1)
       end
       @user.save!
  
       # check for an invitation
       if session[:invite]
         Friend.create_confirmed_friendship(@user, session[:invite].inviter)
         session[:invite] = nil
       end

       redirect_to confirmation_path(@user.login)
     rescue ActiveRecord::RecordInvalid
       render :action => 'new_openid'
     end
    end
  end
  
  def check_wiki
    if logged_in? and (Rails.env == 'production')
      begin
        require 'net/http'
        require 'uri'
        require 'cgi'

        cookie_domain = '.opencongress.org'

        data = "wpName=#{CGI::escape(current_user.login)}&wpPassword=#{ApiKeys.wiki_pass}&wpLoginattempt=Log%20in&#{ApiKeys.wiki_key}=true"

        headers = {
          'Content-Type' => 'application/x-www-form-urlencoded'
        }

        http = Net::HTTP.new(Rails.env.production? ? 'wiki-internal' : WIKI_HOST, 80)

        path = "/w/index.php?title=Special:UserLogin&returnto=Main_Page"
        resp, data = http.post(path,data,headers)

        returned_cookies = resp['set-cookie'].split(',')
        returned_cookies.each do |b|
          b.strip!
          if b =~ /^([A-Za-z0-9_]+)\=([A-Za-z0-9_]+)/
            cookie_name, cookie_value = [$1, $2]
            logger.info cookie_name
            cookies[cookie_name] = {:value => cookie_value, :expires => 30.days.from_now, :domain => cookie_domain, :path => '/'}
          end
        end
      rescue
      end
    end
  end

  def add_openid
      authenticate_with_open_id(params[:identity_url]) do |status, identity_url, registration|
        if status.successful?
          user = User.find_by_id(current_user.id)
          user.identity_url = identity_url
          if user.save
            flash[:notice] = "OpenID identity added"
          else
            flash[:notice] = "A user already exists with that open ID"
          end
        else
          flash[:notice] = "Failed Login"
        end
        redirect_to user_profile_path(current_user.login)
      end
  end

  protected
    def open_id_authentication(identity_url)
      # Pass optional :required and :optional keys to specify what sreg fields you want.
      # Be sure to yield registration, a third argument in the #authenticate_with_open_id block.
      authenticate_with_open_id(identity_url, :required => [:nickname, :email]) do |status, identity_url, registration|
        if status.successful?
          if self.current_user = User.find_by_identity_url(identity_url)
            # registration is a hash containing the valid sreg keys given above
            # use this to map them to fields of your user model
            #              {'login=' => 'nickname', 'email=' => 'email', 'full_name=' => 'fullname'}.each do |attr, reg|
            #                current_user.send(attr, registration[reg]) unless registration[reg].blank?
            #              end
            unless self.current_user.save
              flash[:error] = "Error saving the fields from your OpenID profile: #{current_user.errors.full_messages.to_sentence}"
            end
          else
           u = User.new()
            {'login=' => 'nickname', 'email=' => 'email', 'full_name=' => 'fullname'}.each do |attr, reg|
              u.send(attr, registration[reg]) unless registration[reg].blank?
            end
            if u.save && self.current_user = User.find_by_identity_url(identity_url)
              logger.info "rock on"
            else 
              session[:idurl] = identity_url
              redirect_to :action => 'new_openid' and return
            end
          end
        end
      end
    end

  private
    def root_url
      home_url
    end
    def process_login_actions
      #debugger
      if session[:action] && session[:action][:url]
        case session[:action][:url]
        when /\/bill\/([0-9]{3}-\w{2,})\//
          ident = $1
          if ident
            bill = Bill.find_by_ident(ident)
            if bill
              if session[:login_action][:action_result].to_i == 0
                b = BillVote.find_or_initialize_by_user_id_and_bill_id(current_user.id, bill.id)
                b.support = 0
                b.save
              elsif session[:login_action][:action_result].to_i == 1
                b = BillVote.find_or_initialize_by_user_id_and_bill_id(current_user.id, bill.id)
                b.support = 1
                b.save
              end
            end
          end
        end
      end
      
      if session[:login_action] and session[:login_action][:action_result]
        if session[:login_action][:action_result] == 'track'
          case session[:login_action][:url]
          when /\/bill\/([0-9]{3}-\w{2,})\//
            ident = $1
            if ident
              bill = Bill.find_by_ident(ident)
              if bill
                bookmark = Bookmark.new(:user_id => current_user.id)
                bill.bookmarks << bookmark
              end    
            end
          when /\/([^\/]+)\/[^\/]+\/(\d+)/
            obj = $1
            id = $2
            if id && obj
              object = Object.const_get(obj)
              this_object = object.find_by_id(id)
              if this_object
                bookmark = Bookmark.new(:user_id => current_user.id)
                this_object.bookmarks << bookmark
              end
            end
          end
        elsif session[:login_action][:action_result] == 'contact_congress'
          session[:formageddon_unsent_threads].each do |t|
            thread = Formageddon::FormageddonThread.find(t)
            
            thread.formageddon_sender = current_user
            
            # force the email on the letters to the user email 
            thread.sender_email = current_user.email
            
            thread.save
          end
          
          session[:return_to] = "/contact_congress_letters/delayed_send"
        end
      end
    end
    
end
