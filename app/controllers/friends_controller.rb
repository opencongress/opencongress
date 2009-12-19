class FriendsController < ApplicationController
  #require 'contacts'
  layout 'application'
 
  before_filter :get_user
  before_filter :login_required, :only => [:invite_form, :import_contacts,:invite_contacts,:new,:add,:create,:destroy,:update,:edit,:confirm]
  before_filter :must_be_owner, :only => [:invite_form, :import_contacts,:invite_contacts,:new,:add,:create,:destroy,:update,:edit,:confirm]
  skip_before_filter :store_location, :only => [:add, :invite]
  filter_parameter_logging :gpasswd

  def search
     @results = []
     if params[:email]
       @results = User.find(:all, :conditions => ["LOWER(email) = ?", params[:email].downcase])
     elsif params[:name]
       @results = User.find(:all, :conditions => ["LOWER(full_name) = ?", params[:name].downcase])
     elsif params[:login]
       @results = User.find(:all, :conditions => ["LOWER(login) = ?", params[:login].downcase]) 
     end
     render :action => 'search', :layout => false 
  end

  def invite_form
    render :layout => false
  end

  def tracking_bill
		@bill = Bill.find_by_ident(params[:id])
		@object = @bill
		@users_solr = User.find_users_tracking_bill(@bill)
    @users = User.find_for_tracking_table(current_user, @bill, @users_solr.docs)
		@page_title = "Users tracking #{@bill.title_typenumber_only}"

		if params[:state]
		  @state_abbrev = params[:state]
      if @state_name = State.for_abbrev(@state_abbrev)
   		  @in_my_state_solr = User.find_users_in_states_tracking([params[:state]], @bill, 1000)
  		  @in_my_state = User.find_for_tracking_table(current_user, @bill, @in_my_state_solr.docs)
      end
    elsif logged_in? && !current_user.zipcode.blank?
		  @state_abbrev = current_user.state_cache.first  
      @state_name = State.for_abbrev(@state_abbrev)
		  @in_my_state_solr = User.find_users_in_states_tracking(current_user.state_cache, @bill, 1000)
		  @in_my_state = User.find_for_tracking_table(current_user, @bill, @in_my_state_solr.docs)
		  @in_my_district_solr = User.find_users_in_districts_tracking(current_user.district_cache, @bill, 1000)
		  @in_my_district = User.find_for_tracking_table(current_user, @bill, @in_my_district_solr.docs)
    end
  end

  def tracking_person
    @person = Person.find(params[:id])
		@object = @person
    @users_solr = User.find_users_tracking_person(@person)
    @users = User.find_for_tracking_table(current_user, @person, @users_solr.docs)
 		@page_title = "Users tracking #{@person.short_name}"

		if logged_in? && !current_user.zipcode.blank?
		  @in_my_state_solr = User.find_users_in_states_tracking(current_user.state_cache, @person, 1000)
		  @in_my_state = User.find_for_tracking_table(current_user, @person, @in_my_state_solr.docs)
		  @in_my_district_solr = User.find_users_in_districts_tracking(current_user.district_cache, @person, 1000)
		  @in_my_district = User.find_for_tracking_table(current_user, @person, @in_my_district_solr.docs)
		end
	end

  def tracking_issue
    @issue = Subject.find(params[:id])
    @users_solr = User.find_users_tracking_issue(@issue)
    @users = User.find_for_tracking_table(current_user, @issue, @users_solr.docs)
 		@page_title = "Users tracking #{@issue.term}"

		if logged_in? && !current_user.zipcode.blank?
		  @in_my_state_solr = User.find_users_in_states_tracking(current_user.my_state, @issue, 1000)
		  @in_my_state = User.find_for_tracking_table(current_user, @issue, @in_my_state_solr.docs)
		  @in_my_district_solr = User.find_users_in_districts_tracking(current_user.my_district, @issue, 1000)
		  @in_my_district = User.find_for_tracking_table(current_user, @issue, @in_my_district_solr.docs)
		end

  end

  def tracking_committee
    @committee = Committee.find(params[:id])
    @users_solr = User.find_users_tracking_committee(@committee)
    @users = User.find_for_tracking_table(current_user, @committee, @users_solr.docs)
 		@page_title = "Users tracking the #{@committee.name} Committee"

		if logged_in? && !current_user.zipcode.blank?
		  @in_my_state_solr = User.find_users_in_states_tracking(current_user.my_state, @committee, 1000)
		  @in_my_state = User.find_for_tracking_table(current_user, @committee, @in_my_state_solr.docs)
		  @in_my_district_solr = User.find_users_in_districts_tracking(current_user.my_district, @committee, 1000)
		  @in_my_district = User.find_for_tracking_table(current_user, @committee, @in_my_district_solr.docs)
		end

  end

  def supporting_person
    @person = Person.find(params[:id])
		@object = @person
    @users_solr = User.find_users_supporting_person(@person)
    @users = User.find_for_tracking_table(current_user, @person, @users_solr.docs)
 		@page_title = "Users Supporting #{@person.short_name}"

		if logged_in? && !current_user.zipcode.blank?
		  @in_my_state_solr = User.find_users_in_states_supporting(current_user.state_cache, @person, 1000)
		  @in_my_state = User.find_for_tracking_table(current_user, @person, @in_my_state_solr.docs)
		  @in_my_district_solr = User.find_users_in_districts_supporting(current_user.district_cache, @person, 1000)
		  @in_my_district = User.find_for_tracking_table(current_user, @person, @in_my_district_solr.docs)
		end
  end


  
  def opposing_person
    @person = Person.find(params[:id])
		@object = @person
    @users_solr = User.find_users_opposing_person(@person)
    @users = User.find_for_tracking_table(current_user, @person, @users_solr.docs)
 		@page_title = "Users Opposing #{@person.short_name}"

		if logged_in? && !current_user.zipcode.blank?
		  @in_my_state_solr = User.find_users_in_states_opposing(current_user.state_cache, @person, 1000)
		  @in_my_state = User.find_for_tracking_table(current_user, @person, @in_my_state_solr.docs)
		  @in_my_district_solr = User.find_users_in_districts_opposing(current_user.district_cache, @person, 1000)
		  @in_my_district = User.find_for_tracking_table(current_user, @person, @in_my_district_solr.docs)
		end    
  end

  def supporting_bill
		@bill = Bill.find_by_ident(params[:id])
		@object = @bill
    @users_solr = User.find_users_supporting_bill(@bill)
    @users = User.find_for_tracking_table(current_user, @bill, @users_solr.docs)
 		@page_title = "Users Supporting #{@bill.title_typenumber_only}"

		if logged_in? && !current_user.zipcode.blank?
		  @in_my_state_solr = User.find_users_in_states_supporting(current_user.state_cache, @bill, 1000)
		  @in_my_state = User.find_for_tracking_table(current_user, @bill, @in_my_state_solr.docs)
		  @in_my_district_solr = User.find_users_in_districts_supporting(current_user.district_cache, @bill, 1000)
		  @in_my_district = User.find_for_tracking_table(current_user, @bill, @in_my_district_solr.docs)
		end
  end

  def opposing_bill
		@bill = Bill.find_by_ident(params[:id])
		@object = @bill
    @users_solr = User.find_users_opposing_bill(@bill)
    @users = User.find_for_tracking_table(current_user, @bill, @users_solr.docs)
 		@page_title = "Users Opposing #{@bill.title_typenumber_only}"

		if logged_in? && !current_user.zipcode.blank?
		  @in_my_state_solr = User.find_users_in_states_opposing(current_user.state_cache, @bill, 1000)
		  @in_my_state = User.find_for_tracking_table(current_user, @bill, @in_my_state_solr.docs)
		  @in_my_district_solr = User.find_users_in_districts_opposing(current_user.district_cache, @bill, 1000)
		  @in_my_district = User.find_for_tracking_table(current_user, @bill, @in_my_district_solr.docs)
		end    
  end


  def near_me
		@title_class = "tab-nav"
 		@profile_nav = @user
		@ziplookup = ZipcodeDistrict.zip_lookup(@user.zipcode, @user.zip_four).first
    @user_district = @ziplookup.district
    @in_state = []
    @in_state = @user.find_other_users_in_state(@ziplookup.state) if @user.zipcode
    
  end

  def import_contacts
    @page_title = "#{@user.login}'s Profile"
		@title_class = "tab-nav"
    @breadcrumb = {
      1 => { 'text' => "Profile: #{@user.login}", 'url' => "/users/#{@user.login}/profile" },
      2 => { 'text' => "Friends", 'url' => "/users/#{@user.login}/profile/friends" },
      3 => { 'text' => "Find or Add", 'url' => "/users/#{@user.login}/profile/friends/add"}
    }

    if request.post? && params[:from]
      @results = []
      @already = []
      begin

        case params[:from]
        when "google"
          @results = Contacts::Gmail.new(params[:glogin], params[:gpasswd]).contacts
          @already = User.find(:all, :conditions => ["LOWER(email) in (?)", @results.collect{|p| p[1]}.compact])
        when "yahoo"
          @results = Contacts::Yahoo.new(params[:glogin], params[:gpasswd]).contacts
          @already = User.find(:all, :conditions => ["LOWER(email) in (?)", @results.collect{|p| p[1]}.compact])
        when "hotmail"
          @results = Contacts::Hotmail.new(params[:glogin], params[:gpasswd]).contacts
          @already = User.find(:all, :conditions => ["LOWER(email) in (?)", @results.collect{|p| p[1]}.compact])          
        end
      rescue
        @login_failed = params[:from] 
      end
    end
  end
  def invite_contacts
    if !simple_captcha_valid?
      flash[:notice] = "SPAM Check Failed"
      redirect_to :action => 'import_contacts'
      return
    end
    
    if request.post? && params[:addfriend]
      message = "(this message was sent by #{current_user.email})

Hi, I wanted to encourage you to join OpenCongress so that we can share information about bills and issues in Congress.

Personal Note: #{CGI.escapeHTML(params[:message])}"    
      @results = []
      params[:addfriend].each_key do |k|
        key = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
        FriendInvite.find_or_create_by_inviter_id_and_invitee_email_and_invite_key(current_user.id, k, key)
    
        Emailer::deliver_invite(k, current_user.full_name.blank? ? current_user.login : current_user.full_name, 
                                "#{BASE_URL}account/invited/#{key}", message)
        @results << k
      end
    end
  end

  def like_voters
    @like_voters = @user.votes_like_me
  end

  def show_recent_comments
    @coms = @user.friends.find_by_id(params[:id]).friend.comments.find(:all, :order => "created_at DESC", :limit => 5)
    render :action => 'show_recent_comments', :layout => false
  end
  def show_recent_votes
    @votes = @user.friends.find_by_id(params[:id]).friend.bill_votes.find(:all, :order => "created_at DESC", :limit => 5)
    render :action => 'show_recent_votes', :layout => false
  end
  def add
   if request.post?
      friend_to_be = User.find_by_id(params[:id])
      if current_user.friends.find_by_id(params[:id])
        render :text => "Already your friend!" and return
      end
      current_user.friends.create({:friend_id => friend_to_be.id, :confirmed => false, :user_id => current_user.id})
      render :text => "Added. #{friend_to_be.login} must confirm, however"
   end
  end
  def confirm
    friending = Friend.find_by_friend_id_and_user_id(current_user.id, params[:id])
    if friending
      friending.confirm
      flash[:notice] = "Friend Added"
      redirect_to friends_path(current_user.login)
    else
      redirect_to friends_path(current_user.login)
    end
  end
  def deny
    friending = Friend.find_by_friend_id_and_user_id(current_user.id, params[:id])
    friending.destroy
    flash[:notice] = "Friending Denied"
    redirect_to friends_path(current_user.login)
  end

  def invite
    
    if params[:email].blank?
      @message = "You didn't enter an email address!"
    end
    
    emails = params[:email].split(/,/)
    
    emails.each do |email|
      email.strip!
      
      # first check to see if this person is already is a user
      invited_user = User.find_by_email(email)
      if invited_user
        if (invited_user != current_user) and (current_user.friends.find_by_id(invited_user.id).nil?)
          fr = current_user.friends.find_or_initialize_by_friend_id_and_user_id(invited_user.id, current_user.id)
          fr.confirmed = false
          fr.save
        end
      else    
        # create the invite record
        key = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join)
        FriendInvite.find_or_create_by_inviter_id_and_invitee_email_and_invite_key(current_user.id, email, key)
    
        Emailer::deliver_invite(email, current_user.full_name.blank? ? current_user.login : current_user.full_name, 
                                "#{BASE_URL}account/invited/#{key}", params[:message])
                              
      end
    end
          
    @message = "Your invitations have been sent!"
                  
    render :layout => false
  end
  
  # GET /friends
  # GET /friends.xml
  def index
    @friends = @user.friends.find(:all)
    @fans = @user.fans
    @more_recent_friends_activity = []
    @total_recent_friends_activity = Friend.recent_activity(@friends)
    @recent_friends_ativity = @total_recent_friends_activity.first(12)
    @more_recent_friends_activity = @total_recent_friends_activity[12..23]
    #@page_title = "#{@user.login}'s Friends"
    @page_title = "#{@user.login}'s Profile"
		@profile_nav = @user
		@title_class = "tab-nav"
		@breadcrumb = {
      1 => { 'text' => "Profile: #{@user.login}", 'url' => "/users/#{@user.login}/profile" },
      2 => { 'text' => "Friends", 'url' => "/users/#{@user.login}/profile/friends" }
    }

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @friends.to_xml }
    end
  end

  # GET /friends/1
  # GET /friends/1.xml
  def show
    @friend = @user.friends.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @friend.to_xml }
    end
  end

  # GET /friends/new
  def new
    @friend = @user.friends.new
    @page_title = "#{@user.login}'s Profile"
		@title_class = "tab-nav"
		@profile_nav = @user
		@breadcrumb = {
      1 => { 'text' => "Profile: #{@user.login}", 'url' => "/users/#{@user.login}/profile" },
      2 => { 'text' => "Friends", 'url' => "/users/#{@user.login}/profile/friends" },
      3 => { 'text' => "Find or Add", 'url' => "/users/#{@user.login}/profile/friends/add"}
    }

  end

  # GET /friends/1;edit
  def edit
    @page_title = "Edit a Friend"
    @breadcrumb = {
      1 => { 'text' => "Profile: #{@user.login}", 'url' => "/users/#{@user.login}/profile" },
      2 => { 'text' => "Friends", 'url' => "/users/#{@user.login}/profile/friends" },
      3 => { 'text' => "Edit", 'url' => "/users/#{@user.login}/profile/friends/edit"}
    }
    @friend = @user.friends.find(params[:id])
  end

  # POST /friends
  # POST /friends.xml
  def create
    @friend = @user.friends.new(params[:friend])
    @friend.user_id = current_user.id
    respond_to do |format|
      if @friend.save
        flash[:notice] = 'Friend was successfully created.'
        format.html { redirect_to friend_url(@user.login,@friend) }
        format.xml  { head :created, :location => friend_url(@user.login,@friend) }
      else
        format.html { render :action => 'new' }
        format.xml  { render :xml => @friend.errors.to_xml }
      end
    end
  end

  # PUT /friends/1
  # PUT /friends/1.xml
  def update
    @friend = Friend.find(params[:id])

    respond_to do |format|
      if @friend.update_attributes(params[:friend])
        flash[:notice] = 'Friend was successfully updated.'
        format.html { redirect_to friend_url(@user.login,@friend) }
        format.xml  { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @friend.errors.to_xml }
      end
    end
  end

  # DELETE /friends/1
  # DELETE /friends/1.xml
  def destroy
    @friend = Friend.find(params[:id])
    @friend.destroy

    respond_to do |format|
      format.html { redirect_to friends_url(@user.login) }
      format.xml  { head :ok }
    end
  end
  private 
  def get_user
    @user = User.find_by_login(params[:login])
  end
  def must_be_owner
    if current_user == @user
      return true 
    else
      flash[:error] = "You are not allowed to access that page."
      redirect_to :controller => 'index'
      return false
    end
  end
end
