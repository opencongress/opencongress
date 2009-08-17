class FacebookController < ApplicationController
  before_filter :ensure_application_is_installed_by_facebook_user, :except => [:intro, :update_profiles]
  before_filter :ensure_authenticated_to_facebook, :except => [:intro, :update_profiles]
  before_filter :get_facebook_user, :except => [:intro, :update_profiles]
  
  layout "facebook", :except => :intro

  def index
    respond_to do |format|
      format.fbml # index.fbml.erb
    end
  end
  
  def finish_facebook_login
    #redirect_to :action => 'home'
  end

  def billedit
    respond_to do |format|
      format.fbml # index.fbml.erb
    end
  end
  
  def bill_search
    unless params[:facebook][:bill_search].blank?
      search_text = prepare_tsearch_query(params[:facebook][:bill_search])
      
      @bills = Bill.full_text_search(search_text, { :page => 1, :congresses => ["#{DEFAULT_CONGRESS}"]})
    end
    
    render :partial => 'bill_search_results', :layout => false
  end
  
  def hotbills
    @hot_bill_categories = HotBillCategory.find(:all)

    respond_to do |format|
      format.fbml { render :partial => 'hotbill_search_results', :layout => false }
    end
  end
  
  def mostviewedbills
    @bills = PageView.popular('Bill', DEFAULT_COUNT_TIME, 25)
    @bill_count = 25
    
    respond_to do |format|
      format.fbml { render :partial => 'bill_search_results', :layout => false }
    end  
  end
  
  def addbill
    @bill = Bill.find_by_ident(params[:id])
    fub = FacebookUserBill.new(params[:addbill])
    fub.bill = @bill
    fub.facebook_user = @facebook_user
    fub.save
    
    # right now only validation on bill
    unless fub.errors.empty?
      flash.now[:error] = fub.errors.on "bill_id"
    else
      flash.now[:notice] = "#{@bill.title_typenumber_only} has been added to your profile."
      FacebookPublisher.deliver_profile_update(@facebook_user, facebook_session.user)
      FacebookPublisher.register_bill_to_feed
      FacebookPublisher.deliver_bill_to_feed(facebook_session.user, @bill, fub.action_for_tracking_type)
    end
    
    respond_to do |format|
      format.fbml { render :partial => 'billeditor', :layout => false }
    end
  end
  
  def removebill
    @fub = FacebookUserBill.find_by_id(params[:id])
    bill = @fub.bill
    
    @facebook_user.facebook_user_bills.delete(@fub)
    
    FacebookPublisher.deliver_profile_update(@facebook_user, facebook_session.user)
    flash.now[:notice] = "#{bill.title_typenumber_only} has been removed from your profile."
    
    respond_to do |format|
      format.fbml { render :partial => 'billeditor', :layout => false }
    end
  end
  
  def intro
    @page_title = "OpenCongress on Facebook"
    render :layout => 'application'
  end
  
  def invite
    @install_url = facebook_session.install_url
    
    respond_to do |format|
      format.fbml # index.fbml.erb
    end
  end
  
  def invitesend
    invite_ids = params[:ids]
    
    if invite_ids and !invite_ids.empty?
      flash[:notice] = "Your invitations have been sent.  Thanks for spreading the word about OpenCongress!"
    end
    
    redirect_to :action => 'index'
  end
  
  def update_profiles
    unless local_request?
      redirect_to :controller => 'index'
      return
    end
    
    users = FacebookUser.find(:all)
    
    users.each do |u|
      puts "Updating profile for UID: #{u.facebook_uid}"
      update_facebook_profile(u)
    end
  end
  
  private
  
  def get_facebook_user
    facebook_user_object = facebook_session.user
    @facebook_user = FacebookUser.find_or_create_by_facebook_uid(facebook_user_object.uid)
    @facebook_user.update_attribute('facebook_session_key', facebook_session.session_key)
    
    # also set the request format to FBML
    request.format = :fbml
  end
end
