require 'authenticated_system'

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include AuthenticatedSystem
  include SimpleCaptcha::ControllerHelpers

  before_filter :store_location
  before_filter :current_tab
  before_filter :has_accepted_tos?
  before_filter :get_site_text_page
  before_filter :is_banned?

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
      logger.info "USER APP TOS: #{current_user.accepted_tos}"
      unless current_user.accepted_tos == true
        redirect_to :controller => 'account', :action => 'accept_tos'
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

  def news_blog_count(count)
    if count >= 1000
      "#{(count/1000).floor}K"
    else
      count
    end
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
