class IssueController < ApplicationController
  before_filter :issue_profile_shared, :only => [:show, :comments]
  before_filter :page_view, :only => :show
  skip_before_filter :store_location, :except => [:index, :alphabetical, :by_most_viewed, :by_bill_count, :top_twenty_bills, :show, :top_viewed_bills]

  def index
    redirect_to :action => 'alphabetical', :id => 'A'
  end

  def alphabetical
    @sort = :alphabetical
    @carousel = [ObjectAggregate.popular('Subject', Settings.default_count_time).slice(0..9)]
    
    letter = params[:id]
    if letter.nil?
      redirect_to :action => 'alphabetical', :id => 'A'
    else
      @subjects = Subject.find_by_first_letter letter
      @order = :term
    end

    @page_title = "Issues"
  end

  def quick_search
    @q = params[:q]
    
    unless @q.nil?
      query_stripped = prepare_tsearch_query(@q)
      
      @subjects = Subject.full_text_search(query_stripped, { :page => params[:page], :per_page => 1000})
    end
    
    render :layout => false
  end

  def by_most_viewed
    @sort = :by_most_viewed

    @days = days_from_params(params[:days])

    @order = :most_viewed
    @subjects = ObjectAggregate.popular('Subject', @days).paginate

    @atom = {'link' => url_for(:only_path => false, :controller => 'issue', :action => 'atom_top20'), 'title' => "Top 20 Most Viewed Issues"}
    
    @page_title = "Issues"
    @title_class = "sort"
    @title_desc = SiteText.find_title_desc('issue_index')

    render :action => 'index'
  end

  def by_bill_count
    @sort = :by_bill_count

    @carousel = [ObjectAggregate.popular('Subject', Settings.default_count_time).slice(0..9)] 

    @order = :bill_count
    @subjects = Subject.find(:all, :order => 'bill_count desc, term asc').paginate
    
    @page_title = "Issues"
    @title_class = "sort"
    @title_desc = SiteText.find_title_desc('issue_index')

    render :action => 'index'
  end

  def comments
    id = params[:id].to_i
    @subject = Subject.find_by_id(id)
    unless @subject
       render_404 and return 
    end
    congress = params[:congress] ? params[:congress] : Settings.default_congress
      respond_to do |format|
        format.html {
    @sidebar_stats_object = @subject
    @user_object = @subject
    @page_title_prefix = "U.S. Congress"
    @page_title = @subject.term
    @title_class = "tabs"
    @comments = @subject

          @current_tab = "comments"

          comment_redirect(params[:goto_comment]) and return if params[:goto_comment]

    @atom = {'link' => url_for(:only_path => false, :controller => 'issue', :id => @subject, :action => 'atom'), 'title' => "Major Bill Actions in #{@subject.term}"}
		@hide_atom = true

        }
      end
  end

  def show
    unless @subject
       render_404 and return 
    end

    comment_redirect(params[:goto_comment]) and return if params[:goto_comment]

    @sidebar_stats_object = @subject
    @user_object = @subject
    @page_title_prefix = "U.S. Congress"
    @page_title = @subject.term
    @meta_description = "#{@subject.term}-related bills and votes in the U.S. Congress."
    @comments = @subject
    
    
    @latest_bills = @subject.latest_bills(3, 1)
    @hot_bills = @subject.pvs_categories.collect{|c| c.hot_bills.where(["bills.session=?", Settings.default_congress]) }.flatten
    @key_votes = @subject.pvs_categories.collect{|c| c.key_votes }.flatten
    @groups = @subject.pvs_categories.collect{|c| c.group }.paginate(:page => 1)
    @passed_bills = @subject.passed_bills(3, 1, Settings.available_congresses)
    
    # the following lines could be a little more, eh, efficient
    @related_industries = @subject.pvs_categories.collect{|c| c.crp_sectors }.flatten.collect{ |i| i.crp_industries }.flatten
    @related_industries.concat(@subject.pvs_categories.collect{|c| c.crp_industries }.flatten).flatten
    
    # if params[:filter] == 'enacted'
    #   @bills = @subject.passed_bills(10, params[:page].blank? ? 1 : params[:page])
    # else
    #   @bills = @subject.latest_bills(10, params[:page].blank? ? 1 : params[:page])
    # end
    
    @top_comments = @subject.comments.find(:all,:include => [:comment_scores, :user], :order => "comments.average_rating DESC", :limit => 2)
    @atom = {'link' => url_for(:only_path => false, :controller => 'issue', :id => @subject, :action => 'atom'), 'title' => "Major Bill Actions in #{@subject.term}"}
		@hide_atom = true
		@tracking_suggestions = @subject.tracking_suggestions
  end

  def top_twenty_bills
    @subject = Subject.find(params[:id])
    @bills = @subject.latest_bills(20)
    
    @page_title = "#{@subject.term} - Recent Bills"

  end

  def top_viewed_bills
   @subject = Subject.find(params[:id])
   @bills = @subject.most_viewed_bills(20)
   @page_title = "#{@subject.term} - Most Viewed Bills"

  end

  def atom
    @subject = Subject.find(params[:id])
    
    @actions = @subject.latest_major_actions(20)
    expires_in 60.minutes, :public => true

    render :layout => false
  end

  def atom_top20
    @issues = Subject.top20_viewed
    expires_in 60.minutes, :public => true

    render :action => 'top20_atom', :layout => false
  end

  private

  def issue_profile_shared
    id = params[:id].to_i
    
    if @subject = Subject.find_by_id(id)
      @page_title_prefix = "U.S. Congress"
      @page_title = @subject.term
      @meta_description = "#{@subject.term} on OpenCongress"
      @sidebar_stats_object = @user_object = @comments = @subject
      @page = params[:page] ||= 1   
      @top_comments = @subject.comments.find(:all,:include => [:user], :order => "comments.plus_score_count - comments.minus_score_count DESC", :limit => 2)
      @atom = {'link' => url_for(:only_path => false, :controller => 'issue', :id => @subject, :action => 'atom'), 'title' => "#{@subject.term} activity"}
    else
      flash[:error] = "Invalid bill URL."
      redirect_to :action => 'index'
    end    
  end
  
  def page_view
    if @subject
      key = "page_view_ip:Subject:#{@subject.id}:#{request.remote_ip}"
      unless read_fragment(key)
        @subject.increment!(:page_views_count)
        @subject.page_view
        write_fragment(key, "c", :expires_in => 1.hour)
      end
    end
  end
end
