require 'authenticated_system'

class ApplicationController < ActionController::Base
  protect_from_forgery

  include AuthenticatedSystem
  include SimpleCaptcha::ControllerHelpers
  include Facebooker2::Rails::Controller
  include UrlHelper

  before_filter :facebook_check
  before_filter :store_location
  before_filter :current_tab
  before_filter :has_accepted_tos?
  before_filter :has_district?
  before_filter :get_site_text_page
  before_filter :is_banned?
  before_filter :set_simple_comments

  def facebook_check
    logger.info "@_fb_user_fetched: #{@_fb_user_fetched}"
    logger.info "@_current_facebook_client: #{@_current_facebook_client}"
    logger.info "signed_request_from_logged_out_user? #{signed_request_from_logged_out_user?}"
    logger.info "fb_cookie_hash: #{fb_cookie_hash}"
    logger.info "Facebooker2.secret: #{Facebooker2.secret}"
    logger.info "generate sig: #{generate_signature(fb_cookie_hash,Facebooker2.secret)}" if fb_cookie_hash
    logger.info "hash['sig']: #{fb_cookie_hash['sig']}" if fb_cookie_hash
    
    logger.info "USER: #{current_facebook_user}, CLIENT: #{current_facebook_client}"
    # check to see if the user is logged into and has connected to OC
    if current_facebook_user and current_facebook_client
      logger.info "FACEBOOK LIB"
      begin
        @facebook_user = Mogli::User.find(current_facebook_user.id, current_facebook_client)
      rescue Mogli::Client::HTTPException
        force_fb_cookie_delete
        @facebook_user = nil
      end
    else
      logger.info "NO FACEBOOK LIB"
      @facebook_user = nil
      force_fb_cookie_delete
    end
    
    if @facebook_user
      # the user isn't logged in, try to find the account based on email
      if current_user == :false
        oc_user = User.where(["email=?", @facebook_user.email]).first
      else
        # if the logged-in user's email matches the one from facebook, use that user
        # otherwise, cancel the facebook connect attempt
        if current_user.email == @facebook_user.email
          return unless current_user.facebook_uid.blank?
          oc_user = current_user
        else
          flash[:error] = "The email addresses in your Facebook and OpenCongress accounts do not match.  Could not connect."
          force_fb_cookie_delete
          @facebook_user = nil
          return
        end
      end
        
      if oc_user
        # if, for some reason, we don't have these fields, require them
        if oc_user.login.blank? or oc_user.zipcode.blank? or !oc_user.accepted_tos
          redirect_to :controller => 'account', :action => 'facebook_complete' unless params[:action] == 'facebook_complete'
          return
        end 
      
        # make sure we have facebook uid
        if oc_user.facebook_uid.blank?
          oc_user.facebook_uid = @facebook_user.id
          oc_user.save
          
          flash.now[:notice] = 'Your Facebook account has now been linked to this OpenCongress account!'
        else
          flash.now[:notice] = "Welcome, #{oc_user.login}."
        end
      
        # log the user in
        self.current_user = oc_user
      else
        # new user.  redirect to get essential info
        redirect_to :controller => 'account', :action => 'facebook_complete' unless params[:action] == 'facebook_complete'
        return
      end
    end
  end
  
  def is_valid_email?(e, with_headers = false)
    if with_headers == false
      email_check = Regexp.new('^[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$')
    else
      email_check = Regexp.new('[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]')
    end

    if (e =~ email_check) == nil
      false
    else
      true
    end		
  end

  def days_from_params(days)
    days = days.to_i if (days && !days.kind_of?(Integer))
    return (days && ((days == 7) || (days == 14) || (days == 30) || (days == 365))) ? days.days : Settings.default_count_time
  end

  def comment_redirect(comment_id)
    comment = Comment.find_by_id(comment_id)
    if comment.commentable_type == "Article"
      redirect_to comment.commentable_link.merge(:action => 'view', :comment_page => comment.page, :comment_id => comment_id)
    else
      redirect_to comment.commentable_link.merge(:action => 'comments', :comment_page => comment.page, :comment_id => comment_id)
    end
    @goto_comment = comment
  end

  private

  def has_accepted_tos?
    if logged_in?
      unless current_user.accepted_tos == true
        redirect_to :controller => 'account', :action => 'accept_tos'
      end
    end
  end

  def has_district?
    if logged_in?
      if current_user.state.nil? or current_user.my_district.size != 1
        redirect_to :controller => 'account', :action => 'determine_district' unless (params[:action] == 'determine_district' or params[:action] == 'accept_tos')
      end
    end
  end
  
  def is_banned?
    if logged_in?
      if current_user.is_banned == true
        redirect_to logout_url
      end
    end
  end

  def current_tab
    @current_tab = params[:navtab].blank? ? nil : params[:navtab]
  end
  def admin_login_required
    if !(logged_in? && current_user.user_role.can_administer_users)
      redirect_to :controller => 'admin', :action => 'index'
    end
  end
  def can_text
    if !(logged_in? && current_user.user_role.can_manage_text)
      redirect_to :controller => 'admin', :action => 'index'
    end
  end
  def can_moderate
    if !(logged_in? && current_user.user_role.can_moderate_articles)
      redirect_to :controller => 'admin', :action => 'index'
    end
  end
  def can_blog
    unless (logged_in? && current_user.user_role.can_blog)
      redirect_to :controller => 'admin', :action => 'index'
    end
  end
  def can_stats
    unless (logged_in? && current_user.user_role.can_see_stats)
      redirect_to :controller => 'admin', :action => 'index'
    end
  end
  def no_users
    unless (logged_in? && current_user.user_role.name != "User")
      flash[:notice] = "Permission Denied"
      redirect_to login_url
    end
  end

  def prepare_tsearch_query(text)
    text = text.strip
    
    # remove non alphanumeric 
    text = text.gsub(/[^\w\.\s\-_]+/, "")
    
    # replace multiple spaces with one space 
    text = text.gsub(/\s+/, " ")
    
    # replace spaces with '&'
    text = text.gsub(/ /, "&")
    
    text
  end

  def site_text_params_string(prms)
    ['action', 'controller', 'id', 'person_type', 'commentary_type'].collect{|k|"#{k}=#{prms[k]}" }.join("&")
  end

  def get_site_text_page
    page_params = site_text_params_string(params)
    
    @site_text_page = SiteTextPage.find_by_page_params(page_params)
    @site_text_page = OpenStruct.new if @site_text_page.nil?
  end
  
  def store_location
    unless request.fullpath =~ /^\/stylesheets/ || request.fullpath =~ /^\/images/ || request.xhr?
      session[:return_to] = request.fullpath
    end
  end
  
  
  def render_404(exception = nil)
    if exception
      logger.info "Rendering 404 with exception: #{exception.message}"
    end

    respond_to do |format|
      format.html { render :file => "public/404.html", :status => :not_found }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end

  def set_simple_comments
    @simple_comments = false
  end
  
  def news_blog_count(count)
    return nil if count.blank?
    if count >= 1000
      "#{(count/1000).floor}K"
    else
      count
    end
  end
  

  def random_key
    Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
  
  def force_fb_cookie_delete
    cookies.delete fb_cookie_name
  end
  
  protected
  def dump_session
    logger.info session.to_yaml
  end

  def log_error(exception) #:doc:
    if ActionView::TemplateError === exception
      logger.fatal(exception.to_s)
    else
      logger.fatal(
        "\n\n[#{Time.now.to_s}] #{exception.class} (#{exception.message}):\n    " + 
        clean_backtrace(exception).join("\n    ") + 
        "\n\n"
      )
    end
  end
end
