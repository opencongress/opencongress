class CommentsController < ApplicationController
  skip_before_filter :store_location
  before_filter :login_required, :only => [:flag, :censor, :ban_ip, :add_comment]
  before_filter :admin_login_required, :only => [:censor, :ban_ip]

  def add_comment
    @object = Object.const_get(params[:type]).find_by_id(params[:id])
    if @object
      if @object.kind_of? NotebookItem and !@object.political_notebook.group.nil?
        unless @object.political_notebook.group.owner_or_member?(current_user)
          @error_msg = "You must be a member of the group to post comments!"
          return
        end
      end
      
      @comment = Comment.new(params[:comment])
      
      @comment.commentable_id = @object.id
      @comment.commentable_type = @object.class.to_s

      @comment.user_id = current_user.id if logged_in?
      @comment.ip_address = request.remote_ip

      @simple_comments = true if @object.kind_of? NotebookItem
      
      @parent = nil
      unless params[:comment][:parent_id].blank?
        @parent = Comment.find_by_id(params[:comment][:parent_id])
        @comment.root_id = @parent.root_id
      end
      
      @is_preview = params[:preview_button].nil? ? false : true
      if @is_preview
        @comment.created_at = Time.now
        return
      end
      
      
      dup = Comment.find(:first, :conditions => ["commentable_type = ? AND comment = ? AND commentable_id = ?", @object.class.to_s,@comment.comment,@object.id])
      if dup
        @error_msg = "Duplicate Comment"
        return
      end 

      if logged_in? 
        unless @comment.save
          @error_msg = "Failed to save."
          return
        end
      else
        @error_msg = "Must Be Logged In To Comment"
        return
      end

      # if this is a reply, make it a child, otherwise, make it a parent
      if @parent
        if @parent.children.empty?
          @comment.move_to_child_of @parent
        else
          # normally, we just would do: @comment.move_to_child_of parent
          # but move_to_child_of adds to the left of siblings, and we want the right
          @comment.move_to_right_of @parent.children.last
        end
        
        # if this is a reply to a comment, just render the new comment
        @reply = true
      else
        @comment.update_attribute('root_id', @comment.id)
        params[:comment_page] = @comment.page
        @reply = false
      end      
    else
      flash[:warning] = "Huh?...Logged"
      redirect_to '/' 
    end
  end

  def showcomfield
    object = Object.const_get(params[:type]).find_by_id(params[:object])
    @simple_comments = true if object.kind_of? NotebookItem
    render :partial => "shared/comments_add_reply", :locals => {:parent_id => params[:parent_id], :object => object } 
  end

  def rate
    # as of Nov 21, 2010 we are only allowing positive comment ratings (value = 10)
    # due to rampant comment bombing
    return if (params[:value].nil? || params[:value].to_i < 10)
      
    comment = Comment.find_by_id(params[:id])
    
    # first check the ip to see if someone is bombing a comment
    ip_score = CommentScore.find_by_comment_id_and_ip_address(comment.id, request.remote_ip)
    if ip_score
      render :update do |page|
        page.replace_html "comm_score_" + comment.id.to_s, "<span id='comm_score_#{comment.id.to_s}' style='color:red'>X</span>"      
    	  page.visual_effect :pulsate, "comm_score_" + comment.id.to_s
      end
      return
    end
    
    score = current_user.comment_scores.find_by_comment_id(comment.id)
      unless score
        score = current_user.comment_scores.create(:user_id => current_user.id, :comment_id => comment.id, :score => params[:value], :ip_address => request.remote_ip)
        if score.score > 5
          comment.plus_score_count = comment.plus_score_count.to_i + 1
          id = "plus"
        else
          comment.minus_score_count = comment.minus_score_count.to_i + 1
          id = "minus"
        end
      else
        if score.score == params[:value].to_i
          if score.score > 5
            comment.plus_score_count = comment.plus_score_count.to_i - 1
          else
            comment.minus_score_count = comment.minus_score_count.to_i - 1
          end
          score.destroy
        else 
          if score.score > 5
            comment.plus_score_count = comment.plus_score_count.to_i - 1
            comment.minus_score_count = comment.minus_score_count.to_i + 1
            id = "minus"
          else
            comment.plus_score_count = comment.plus_score_count.to_i + 1
            comment.minus_score_count = comment.minus_score_count.to_i - 1
            id = "plus"
          end
        score.score = params[:value]
        end
      end  
    score.save
    if comment.comment_scores.length >= 6
      comment.average_rating = comment.comment_scores.average(:score)
    end
    comment.save
    logger.info params.to_yaml
   
    render :update do |page|
      page.select("#rate_comment_#{comment.id.to_s} a.active").each do |a|
        a.remove_class_name 'active'
      end
      if id
        page.select("#rate_comment_#{comment.id.to_s} ##{id}").each do |a|
          a.add_class_name 'active'
        end
      end
      page.replace_html "comm_score_" + comment.id.to_s, "<span id='comm_score_#{comment.id.to_s}' style='color:#{integer_to_color(comment.score_count_sum.to_i)}'>#{comment.score_count_sum.to_s}</span>"      
      page.replace_html "comm_overall_" + comment.id.to_s, "<span id='rates_more_overall_#{ comment.id }'>Overall Rating: #{h number_with_precision(comment.average_rating,:precision => 1) }
  		  &nbsp;|&nbsp;&nbsp;#{ comment.plus_score_count } of #{ comment.score_count_all } found useful.</span>"
  	  page.visual_effect :pulsate, "comm_score_" + comment.id.to_s
    end
  end
  def filter_by_rating
    redirect_to '/' and return unless params[:type]
    page = 1 unless params[:comment_page].to_i > 1
    page = params[:comment_page].to_i unless page
    object = Object.const_get(params[:type]).find_by_id(params[:id])
    if object
      if params[:comment_sort] == 'rating' 
        comments = object.comments.paginate(:page => page, :include => [:user], :order => "comments.plus_score_count - comments.minus_score_count DESC" )
      elsif params[:comment_sort] == 'newest'
        comments = object.comments.paginate(:page => page, :include => [:user], :order => "comments.created_at DESC" ) 
      else
        comments = object.comments.paginate(:page => page, :include => [:user], :order => "comments.root_id ASC, comments.lft ASC" ) 
      end
      @comments = comments.select{|p| p.average_rating < params[:value].to_f}
      # object.comments.find(:all, :conditions => ["average_rating < ?", params[:value]])
      @showcomments = comments.select{|p| p.average_rating >= params[:value].to_f}
      #object.comments.find(:all, :conditions => ["average_rating >= ?", params[:value]])
    end 
  end
  def censor
    comment = Comment.find_by_id(params[:id])

    if params[:commit] == "Censor+BanIP"
      if comment && !comment.ip_address.blank? && comment.ip_address !=~ /^127./
        noob = ApacheBan.create_by_ip(comment.ip_address)
        flash[:notice] = "IP #{comment.ip_address} banned"
    
      else
        flash[:notice] = "No IP associated with that comment."
      end
    end
    
    comment.update_attribute(:censored, true)
    redirect_back_or_default('/')
  end
  
  def flag
    @comment = Comment.find_by_id(params[:id])
    @comment.update_attribute(:flagged, true)
    flash[:notice] = "Comment has been Flagged."
    redirect_to url_for(@comment.commentable_link.merge({:goto_comment => @comment.id}))
  end
  
  def atom_comments
    @comments = []
    @object_type = params[:object]
    if params[:object] == 'bill'
      @object = Bill.find_by_id(params[:id])
      @title = "Comments on #{@object.title_full_common}"
    elsif params[:object] == 'person'
      @object = Person.find_by_id(params[:id])
      @title = "Comments on #{@object.name}"
    end
    
    if @object
      @comments = @object.comments.find(:all, :limit => 20)
    end
    
    render :layout => false
  end
  
  def bill_text_comments
    return if params[:version].blank? or params[:nid].blank?
    
    @comments = []
    @nid = params[:nid]
    btv = BillTextVersion.find_by_id(params[:version])
    @btn = btv.bill_text_nodes.find_or_create_by_nid(@nid)
    
    respond_to do |format|
      format.html
      format.js
    end
  end
end
