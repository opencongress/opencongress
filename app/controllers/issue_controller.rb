
class IssueController < ApplicationController
  before_filter :issue_profile_shared, :only => [:show, :comments]
  skip_before_filter :store_location, :except => [:index, :alphabetical, :by_most_viewed, :by_bill_count, :top_twenty_bills, :show, :top_viewed_bills]

  def index
      redirect_to :action => 'alphabetical', :id => 'A'
  end

  def alphabetical
    @sort = :alphabetical
    
    @custom_sidebar = Sidebar.find_by_page_and_enabled('issue_alphabetical', true)
    @carousel = [PageView.popular('Subject', DEFAULT_COUNT_TIME).slice(0..9)]
    
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

    @custom_sidebar = Sidebar.find_by_page_and_enabled('issue_by_most_viewed', true)

    @order = :most_viewed
    @subjects = PageView.popular('Subject', @days).paginate

    @atom = {'link' => url_for(:only_path => false, :controller => 'issue', :action => 'atom_top20'), 'title' => "Top 20 Most Viewed Issues"}
    
    @page_title = "Issues"
    @title_class = "sort"
    @title_desc = SiteText.find_title_desc('issue_index')

    @breadcrumb = { 
      1 => { 'text' => "Issues", 'url' => { :controller => 'issue'} }
    }
    render :action => 'index'
  end

  def by_bill_count
    @sort = :by_bill_count

    #@custom_sidebar = Sidebar.find_by_page_and_enabled('issue_by_bill_count', true)
    @carousel = [PageView.popular('Subject', DEFAULT_COUNT_TIME).slice(0..9)] 

    @order = :bill_count
    @subjects = Subject.find(:all, :order => 'bill_count desc, term asc').paginate
    
    @page_title = "Issues"
    @title_class = "sort"
    @title_desc = SiteText.find_title_desc('issue_index')
    
    @breadcrumb = { 
      1 => { 'text' => "Issues", 'url' => { :controller => 'issue' } }
    }
    render :action => 'index'
  end

  def comments
    id = params[:id].to_i
    @subject = Subject.find_by_id(id)
    unless @subject
       render :partial => "index/notfound_page", :layout => 'application', :status => "404" and return 
    end
    congress = params[:congress] ? params[:congress] : DEFAULT_CONGRESS
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

    @breadcrumb = { 
      1 => { 'text' => "Issues", 'url' => { :controller => 'issue'} },
      2 => { 'text' => @subject.term, 'url' => { :controller => 'issue', :action => 'show', :id => @subject } }
    }
    @atom = {'link' => url_for(:only_path => false, :controller => 'issue', :id => @subject, :action => 'atom'), 'title' => "Major Bill Actions in #{@subject.term}"}
		@hide_atom = true

        }
      end
  end

  def show
    unless @subject
       render :partial => "index/notfound_page", :layout => 'application', :status => "404" and return 
    end
    PageView.create_by_hour(@subject, request)

    comment_redirect(params[:goto_comment]) and return if params[:goto_comment]

    @br_link = Rails.cache.fetch("issue_link_#{@subject.id}", :expires_in => 20.minutes) {
         @subject.br_link
    }
	
    @sidebar_stats_object = @subject
    @user_object = @subject
    @page_title_prefix = "U.S. Congress"
    @page_title = @subject.term
    @meta_description = "#{@subject.term}-related bills and votes in the U.S. Congress."
    @comments = @subject
    @latest_bills = @subject.latest_bills(10, params[:page].blank? ? 1 : params[:page])
    @top_comments = @subject.comments.find(:all,:include => [:comment_scores, :user], :order => "comments.average_rating DESC", :limit => 2)
    @atom = {'link' => url_for(:only_path => false, :controller => 'issue', :id => @subject, :action => 'atom'), 'title' => "Major Bill Actions in #{@subject.term}"}
		@hide_atom = true
		@tracking_suggestions = @subject.tracking_suggestions
  end

  def top_twenty_bills
    @subject = Subject.find(params[:id])
    @bills = @subject.latest_bills(20)
    
    @page_title = "#{@subject.term} - Recent Bills"
    @breadcrumb = { 
      1 => { 'text' => "Issues", 'url' => { :controller => 'issue'} },
      2 => { 'text' => @subject.term, 'url' => { :controller => 'issue', :action => 'show', :id => @subject } },
      3 => { 'text' => "Recent Bills", 'url' => { :controller => 'issue', :action => 'top_twenty_bills', :id => @subject } }
    }
  end

  def top_viewed_bills
   @subject = Subject.find(params[:id])
   @bills = @subject.most_viewed_bills(20)
   @page_title = "#{@subject.term} - Most Viewed Bills"
    @breadcrumb = {
      1 => { 'text' => "Issues", 'url' => { :controller => 'issue'} },
      2 => { 'text' => @subject.term, 'url' => { :controller => 'issue', :action => 'show', :id => @subject } },
      3 => { 'text' => "Most Viewed Bills", 'url' => { :controller => 'issue', :action => 'top_twenty_bills', :id => @subject } }
    }
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
end
