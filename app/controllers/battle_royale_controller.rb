class BattleRoyaleController < ApplicationController
 
  before_filter :get_range

  def index
    redirect_to :controller => 'bill', :action => 'hot'
  end

  def senators
    redirect_to :controller => 'people', :action => 'senators'
  end

  def representatives
    redirect_to :controller => 'people', :action => 'representatives'
    return
    
    @person = Person.find(params[:person]) if params[:person]

    sort = params[:sort] ||= "bookmark_count_1"
		order = params[:order] ||= "desc"
    @p_title_class = "reps"
    @p_title = "Representatives"
    if order == "asc"
      @p_subtitle = "Least "
    else
      @p_subtitle = "Most "
    end
    case sort
      when "bookmark_count_1"
       @p_subtitle << "Users Tracking"
      when "p_approval_count"
        @p_subtitle << "User Approval Votes"
      when "p_approval_avg"
        @p_subtitle << "Average User Approval"
      when "total_comments"
        @p_subtitle << "Comments"
    end
    page = params[:page] ||= 1
#    @cache_key = "br-reps-#{page}-#{sort}-#{order}-#{logged_in? ? current_user.login : nil}-#{@range}-#{params[:q].blank? ? nil : Digest::SHA1.hexdigest(params[:q])}"
#    unless read_fragment(@cache_key)
      unless params[:q].blank?    
        @r_count = Person.count_all_by_most_tracked_for_range(@range, :search => prepare_tsearch_query(params[:q]), :order => sort + " " + order, :per_page => 20, :page => page, :person_type => "Rep.")
        @results = Person.paginate_by_most_tracked_for_range(@range, :search => prepare_tsearch_query(params[:q]), :order => sort + " " + order, :per_page => 20, :page => page, :person_type => "Rep.", :total_entries => @r_count)
      else
        @r_count = Person.count_all_by_most_tracked_for_range(@range, :order => sort + " " + order, :per_page => 20, :page => page, :person_type => "Rep.")
        @results = Person.paginate_by_most_tracked_for_range(@range, :order => sort + " " + order, :per_page => 20, :page => page, :person_type => "Rep.", :total_entries => @r_count)
      end
#    end
#    get_counts
    
    respond_to do |format|
     format.html {
       render :action => 'person_by_approval_rating'
     }
     format.xml {
       render :xml => @results.to_xml(:except => [:bookmark_count_2,
                                                  :fti_names,:current_support_pb, :support_count_1, :rolls, :hot_bill_category_id, 
                                                  :support_count_2, :vote_count_2]) 
     }

    end    

  end

  def issues
    redirect_to :controller => 'issues', :action => 'index'
    return

    @issue = Subject.find(params[:issue]) if params[:issue]
    
    sort = params[:sort] ||= "bookmark_count_1"
		order = params[:order] ||= "desc"
    @p_title_class = "issues"
    @p_title = "Issues"
    if order == "asc"
      @p_subtitle = "Least "
    else
      @p_subtitle = "Most "
    end
    case sort
      when "bookmark_count_1"
       @p_subtitle << "Users Tracking"
      when "total_comments"
        @p_subtitle << "Comments"
    end
    page = params[:page] ||= 1
#    @cache_key = "br-issues-#{page}-#{sort}-#{order}-#{logged_in? ? current_user.login : nil}-#{@range}-#{params[:q].blank? ? nil : Digest::SHA1.hexdigest(params[:q])}"
#    unless read_fragment(@cache_key)
      unless params[:q].blank?   
        @r_count = Subject.count_all_by_most_tracked_for_range(@range, :search => prepare_tsearch_query(params[:q]), :order => sort + " " + order, :per_page => 20, :page => page)
        @results = Subject.paginate_by_most_tracked_for_range(@range, :search => prepare_tsearch_query(params[:q]), :order => sort + " " + order, :per_page => 20, :page => page, :total_entries => @r_count)
      else
        @r_count = Subject.count_all_by_most_tracked_for_range(@range, :order => sort + " " + order, :per_page => 20, :page => page)
        @results = Subject.paginate_by_most_tracked_for_range(@range, :order => sort + " " + order, :per_page => 20, :page => page, :total_entries => @r_count)
      end
#    end
    respond_to do |format|
     format.html {
       render :action => 'most_tracked_issues'
     }
     format.xml {
       render :xml => @results.to_xml(:except => [:bookmark_count_2,:fti_names,:current_support_pb, :support_count_1, :rolls, :hot_bill_category_id, :support_count_2, :vote_count_2]) 
     }

    end   
  end    

  def show_bill_details
    @bill = Bill.find_by_id(params[:id])
    render :action => 'show_bill_details', :layout => false
  end
end
