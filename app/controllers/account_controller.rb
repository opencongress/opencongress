class AccountController < ApplicationController
  before_filter :login_from_cookie, :except => [:reset_password]
  before_filter :login_required, :only => [:welcome, :accept_tos]
  after_filter :check_forums, :only => [:login, :activate]
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
    if params[:id] == API_KEYS['wiki_callback_key']
      user = User.find(:first, :conditions => ["lower(login) = ?", params[:login].downcase])
      render :text => "#{user.email}"
    else
      redirect_to :action => :index
    end
  end

  def get_user_full_name
    if params[:id] == API_KEYS['wiki_callback_key']
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
      session[:return_to] = "#{WIKI_BASE_URL}/#{params[:wiki_return_page]}"
    end
    if using_open_id?
       open_id_authentication(params[:openid_url])
    elsif params[:user]
      beer = User.find_by_login(params[:user][:login])
      logger.info beer.to_yaml
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
        logger.info "USER TOS: #{user.accepted_tos}"
        self.current_user = User.find_by_id(user.id)
        redirect_back_or_default(user_profile_path(:login => current_user.login))
      end
    end
  end

  def signup
   @page_title = "Create a New Account"

    logger.info session.inspect
    
    @user = User.new(params[:user])
    @user.email = session[:invite].invitee_email unless session[:invite].nil? or request.post?
    
    return unless request.post?

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
    
    redirect_to(:controller => 'account', :action => 'confirm', :login => @user.login)
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end

  def confirm
    @user = User.find_by_login(params[:login], :conditions => ["activated_at is null"])
  end

  def logout
    if params[:wiki_return_page]
      session[:return_to] = "http://www.opencongress.org/wiki/#{params[:wiki_return_page]}"
    end    
    redirect_loc = session[:return_to]
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    cookies.delete '_session_id'
    # Forum Integration
    cookies.delete 'lussumocookieone'
    cookies.delete 'lussumocookietwo'
    cookies.delete 'ocloggedin'
    cookies['PHPSESSID'] = {:value => '', :path => '/', :expires => Time.at(0), :domain => ".www.opencongress.org" }
    cookies['PHPSESSID'] = {:value => '', :path => '/', :expires => Time.at(0), :domain => ".opencongress.org" }
    cookies['PHPSESSID'] = {:value => '', :path => '/', :expires => Time.at(0), :domain => ".www.opencongress.org" }
    cookies.delete 'wikiToken', {:domain => '.opencongress.org'}
    cookies.delete 'wiki_session', {:domain => '.opencongress.org'}
    cookies.delete 'wikiUserID', {:domain => '.opencongress.org'}
    cookies.delete 'wikiUserName', {:domain => '.opencongress.org'}
    
    reset_session
    session[:return_to] = redirect_loc
    flash[:notice] = "You have been logged out."
    
    #redirect_back_or_default('/')
    redirect_to :controller => 'index'
  end
  
  def activate
   @user = User.find_by_activation_code(params[:id])
   if @user and @user.activate
     self.current_user = @user
     redirect_to welcome_url
     return
  else
     flash[:notice] = "We didn't find that confirmation code; maybe you've already activated your account?"
     redirect_to signup_url
     return
   end

  end

  def welcome
    @user = current_user
    @show_tracked_list = true
    @most_viewed_bills = PageView.popular('Bill', DEFAULT_COUNT_TIME, 5)
    @senators, @reps = Person.find_current_congresspeople_by_zipcode(@user.zipcode, @user.zip_four) if ( logged_in? && @user == current_user && !(@user.zipcode.nil? || @user.zipcode.empty?))
  end

  def forgot_password
    @breadcrumb = {
      1 => { 'text' => "Forgot Password", 'url' => "/account/forgot_password" }
    }

    return unless request.post?
    if @user = User.find_by_email(params[:user][:email])
      @user.forgot_password
      @user.save!
#      redirect_back_or_default(:controller => 'account', :action => 'index')
      @page_title = "Forgot Password"
      render :action => 'pwmail'
    else
      flash[:notice] = "Could not find a user with that email address"
    end
  end

  def reset_password
    redirect_to '/account/forgot_password' and return if params[:id].blank?
    @user = User.find_by_password_reset_code(params[:id])
    @breadcrumb = {
      1 => { 'text' => "Reset Password", 'url' => "/account/reset_password" }
    }
    raise if @user.nil?
    return if @user unless request.post?
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

       redirect_to(:controller => '/account', :action => 'confirm', :login => @user.login)
     rescue ActiveRecord::RecordInvalid
       render :action => 'new_openid'
     end
    end
  end
  
  def check_forums
   if logged_in?
     begin
       fuser = Forum.find(:first, :conditions => ["Name = ?", current_user.login])
       unless fuser
          fuser = Forum.create({:Name => current_user.login, :Password => current_user.crypted_password, :RoleID => 3, :DateFirstVisit => Time.new(), :DateLastActive => Time.new()})
       end
       vkey = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
       fuser.VerificationKey = vkey
       fuser.save
       cookies[:lussumocookieone] = fuser.UserID.to_s
       cookies[:lussumocookietwo] = vkey
     rescue
     end
   end
  end

  def check_wiki
    if logged_in?
      begin
        require 'net/http'
        require 'uri'
        require 'cgi'

        cookie_domain = '.opencongress.org'

        data = "wpName=#{CGI::escape(current_user.login)}&wpPassword=#{API_KEYS['wiki_pass']}&wpLoginattempt=Log%20in&#{API_KEYS['wiki_key']}=true"

        headers = {
          'Content-Type' => 'application/x-www-form-urlencoded'
        }

        http = Net::HTTP.new(RAILS_ENV == 'production' ? 'wiki.opencongress.org' : WIKI_BASE_URL.gsub(/http:\/\//,''), 80)

        path = "/index.php?title=Special:UserLogin&returnto=Main_Page"
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

#  def open_id_authentication
#    authenticate_with_open_id do |result, identity_url|
#      if result.successful?
#        self.current_user = User.find_or_create_by_identity_url(identity_url)
#      end
#    end
#  end
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
              b = BillVote.find_or_create_by_user_id_and_bill_id(current_user.id, bill.id)
              b.support = 0
              b.save
            elsif session[:login_action][:action_result].to_i == 1
              b = BillVote.find_or_create_by_user_id_and_bill_id(current_user.id, bill.id)
              b.support = 1
              b.save
            end
          end
        end
      end
    if session[:login_action][:action_result]
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
      end
    end
  end
  end
    
end
