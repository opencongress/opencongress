class Admin::CommentsController < Admin::IndexController
  before_filter :admin_login_required
  skip_before_filter :store_location, :only => ["bulk_operations"]


  def index
    if params[:flagged_only]
      @teh_comments = Comment.where("flagged=? AND censored=?", true, false).order("created_at ASC").paginate(:page => params[:page], :per_page => 100)
      @page_title = "Flagged Comments"
    elsif params[:spam]
      @page_title = "Spam Comments"
      @teh_comments = Comment.spam.paginate(:page => params[:page], :per_page => 100)
    else
      @page_title = "Comment Moderation"
      @teh_comments = Comment.where("censored=?", false).order("created_at ASC").paginate(:page => params[:page], :per_page => 100)
    end
  end
  
  def comments_search
    if request.post?
      @comments = Comment.find(:all, :conditions => ["comment LIKE ?", "%#{params[:q]}%"])
      @comments = nil if @comments.empty?
      if params[:delete_comms]
        @comments.each do |c|
          c.destroy
        end
        @comments = nil
      end
    end
  end
  
  def bulk_operation
    
    if params[:ban_ip]
    params[:ban_ip].each do |commentid|
      comment = Comment.find_by_id(params[:id])
      if comment && !comment.ip_address.blank? && comment.ip_address !=~ /^127./
        noob = ApacheBan.create_by_ip(comment.ip_address)
      end
      comment = nil
    end
    end
    
    if params[:warn_user]
      params[:warn_user].each do |commentid|
        comment = Comment.find_by_id(commentid)
        if comment && comment.user
          comment.comment_warn(current_user)
          comment.update_attribute(:censored, true)
        end
      end
    end
    
    unless params[:ban_user].nil? || params[:ban_user].empty?
      comments = Comment.find_all_by_id(params[:ban_user])
      users = comments.collect {|p| p.user_id}.compact.uniq.flatten
      Comment.update_all("censored = true", ["id in (?)", params[:ban_user]])
      User.update_all("is_banned = true", ["id in (?)", users]) unless users.empty?
    end    

    unless params[:censor].nil? || params[:censor].empty?
      Comment.update_all("censored = true", ["id in (?)", params[:censor]])
    end

    unless params[:ok].nil? || params[:ok].empty?
      Comment.update_all("ok = true", ["id in (?)", params[:ok]])
      Comment.update_all("flagged = false", ["id in (?)", params[:ok]])
      Comment.update_all("spam = false", ["id in (?)", params[:ok]])
    end
    

    unless params[:unflag].nil? || params[:unflag].empty?
      Comment.update_all("flagged = false", ["id in (?)", params[:unflag]])
    end

    redirect_to('/admin/comments?flagged_only=true')

  end

  def set_ok
    @tis_admin = true
    c = Comment.find_by_id(params[:id])
    c.update_attribute(:ok, true)
    render :update do |page|
      page.hide("comment#{c.id}")
    end
  end
  
  def warn_user
    @c = Comment.find_by_id(params[:id])
    @user = c.user
    @user.comment_warn(@c, current_user)
  end
  
  def unflag
    @tis_admin = true
    c = Comment.find_by_id(params[:id])
    c.update_attribute(:flagged, false)
    render :update do |page|
      page.hide("comment#{c.id}")
    end    
  end

  def censor
    @tis_admin = true
    comment = Comment.find_by_id(params[:id])
    comment.update_attribute(:censored, true)
    render :update do |page|
      page.hide("comment#{comment.id}")
    end
  end

end
