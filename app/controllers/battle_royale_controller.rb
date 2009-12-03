class BattleRoyaleController < ApplicationController
 
  before_filter :get_range

  def index
    @bill = Bill.find_by_ident(params[:bill]) if params[:bill]
    @p_title_class = "bills"
    @p_title = "Bills"
    order = params[:order] ||= "desc" 
    if order == "asc"
      @p_subtitle = "Least "
    else
      @p_subtitle = "Most "
    end
    sort = params[:sort] ||= "vote_count_1"
    case sort
      when "vote_count_1"
        @p_subtitle << "Votes"
      when "current_support_pb"
        @p_subtitle << "Support"
      when "support_count_1"
        @p_subtitle << "Opposition"
      when "bookmark_count_1"
        @p_subtitle << "Users Tracking"
      when "total_comments"
        @p_subtitle << "Comments"
    end
    page = params[:page] ||= 1
    
#    @cache_key = "br-bill-#{page}-#{sort}-#{order}-#{logged_in? ? current_user.login : nil}-#{@range}-#{params[:q].blank? ? nil : Digest::SHA1.hexdigest(params[:q])}"
#    unless read_fragment(@cache_key)
      unless params[:q].blank?
        @r_count = Bill.count_all_by_most_user_votes_for_range(@range, :search => prepare_tsearch_query(params[:q]), :order => sort + " " + order, :per_page => 20, :page => page)
        @results = Bill.paginate_by_most_user_votes_for_range(@range, :search => prepare_tsearch_query(params[:q]), :order => sort + " " + order, :per_page => 20, :page => page, :total_entries => @r_count)        
      else
        @r_count = Bill.count_all_by_most_user_votes_for_range(@range, :order => sort + " " + order, :per_page => 20, :page => page)
        @results = Bill.paginate_by_most_user_votes_for_range(@range, :order => sort + " " + order, :per_page => 20, :page => page, :total_entries => @r_count)    
      end
#    end
#     get_counts
     respond_to do |format|
       format.html {
         render :action => "index"
       }
       format.xml {
         render :xml => @results.to_xml(:methods => [:title_full_common, :status, :ident], 
                                        :except => [:rolls, :hot_bill_category_id, :summary, 
                                                    :current_support_pb, :support_count_1, :rolls, :hot_bill_category_id, 
                                                    :support_count_2, :vote_count_2]) 
       }

     end
  end

  def senators
    @person = Person.find(params[:person]) if params[:person]

    sort = params[:sort] ||= "bookmark_count_1"
    order = params[:order] ||= "desc"
    @p_title_class = "sens"
		@p_title = "Senators"
		order = params[:order] ||= "desc" 
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
#    @cache_key = "br-sens-#{page}-#{sort}-#{order}-#{logged_in? ? current_user.login : nil}-#{@range}-#{params[:q].blank? ? nil : Digest::SHA1.hexdigest(params[:q])}"
#    unless read_fragment(@cache_key)    
      unless params[:q].blank?    
        @r_count = Person.count_all_by_most_tracked_for_range(@range, :search => prepare_tsearch_query(params[:q]), :order => sort + " " + order, :per_page => 20, :page => page)
        @results = Person.paginate_by_most_tracked_for_range(@range, :search => prepare_tsearch_query(params[:q]), :order => sort + " " + order, :per_page => 20, :page => page, :total_entries => @r_count)
      else
        logger.info "Person.count_all_by_most_tracked_for_range(#{@range}, :order => \"#{sort} #{order}\", :per_page => 20, :page => #{page})"
        @r_count = Person.count_all_by_most_tracked_for_range(@range, :order => sort + " " + order, :per_page => 20, :page => page)
        logger.info @r_count.to_yaml
        
        @results = Person.paginate_by_most_tracked_for_range(@range, :order => sort + " " + order, :per_page => 20, :page => page, :total_entries => @r_count)
      end
#    end
#    get_counts
    respond_to do |format|
     format.html {
       render :action => "person_by_approval_rating"
     }
     format.xml {
       render :xml => @results.to_xml(:except => [:bookmark_count_2,:fti_names,:current_support_pb, :support_count_1, :rolls, :hot_bill_category_id, :support_count_2, :vote_count_2]) 
     }

    end    

  end

  def representatives
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
       render :action => "person_by_approval_rating"
     }
     format.xml {
       render :xml => @results.to_xml(:except => [:bookmark_count_2,
                                                  :fti_names,:current_support_pb, :support_count_1, :rolls, :hot_bill_category_id, 
                                                  :support_count_2, :vote_count_2]) 
     }

    end    

  end

  def issues
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
       render :action => "most_tracked_issues"
     }
     format.xml {
       render :xml => @results.to_xml(:except => [:bookmark_count_2,:fti_names,:current_support_pb, :support_count_1, :rolls, :hot_bill_category_id, :support_count_2, :vote_count_2]) 
     }

    end   
  end    

  def show_bill_details
    @bill = Bill.find_by_id(params[:id])
    render :action => "show_bill_details", :layout => false
  end
  
  def br_bill_vote
     @bill = Bill.find_by_ident(params[:bill])
       @bv = current_user.bill_votes.find_by_bill_id(@bill.id)
       unless @bv
         @bv = current_user.bill_votes.create({:bill_id => @bill.id, :user_id  => current_user.id, :support => (params[:id] == "1" ? 1 : 0) }) unless @bv
         update = {(params[:id] == "1" ? 'oppose' : 'support') => '+'}
       else
         if params[:id] == "1"
            if @bv.support == true
               @bv.destroy
               update = {'oppose' => '-'}
            else
               @bv.support = true
               @bv.save
               update = {'oppose' => '+', 'support' => '-'}
            end
         else
            if @bv.support == false
               @bv.destroy
               update = {'support' => '-'}
            else
               @bv.support = false
               @bv.save
               update = {'support' => '+', 'oppose' => '-'}
            end
         end
       end                                         
       render :update do |page|
         page.replace_html 'vote_results_' + @bill.id.to_s, :partial => "/bill/bill_votes"
           
           update.each_pair do |view, op|
             page << "$('#{view}_#{@bill.id.to_s}').update(parseInt($('#{view}_#{@bill.id.to_s}').innerHTML)#{op}1)"
             page.visual_effect :pulsate, "#{view}_#{@bill.id.to_s}"
           end
       end
     
   end
    
  private

  def get_range
    @head_title = "Battle Royale - What's Popular in Congress"
    params[:timeframe] ||= "30days"
    case params[:timeframe]
      when "1day"
        @range = 1.day.to_i
      when "5days"
        @range = 5.days.to_i
      when "30days"
        @range = 30.days.to_i
      when "1year"
        @range = 1.year.to_i
      when "AllTime"
        @range = 20.years.to_i
    end
    
    @perc_diff_in_days = Bill.percentage_difference_in_periods(@range).to_f
    
    @time_collection = [["1 Day","1day"],
                        ["5 Days","5days"],
                        ["30 Days","30days"],
                        ["1 Year","1year"],
                        ["All Time","AllTime"]]

    
  end
  
  def get_counts
    objects = @results.collect{|p| p.id}
    object_type = @results.first.class.to_s
    if object_type == "Person"
      
       @blog_count = {}
       Commentary.count(:id, :conditions => ["is_news = ? AND commentariable_type = 'Person' AND commentariable_id in (?) AND created_at > ?", false, objects, @range.seconds.ago], :group => "commentariable_id").each {|x| @blog_count[x[0]] = x[1]}
#       logger.info @blog_count.to_yaml
       @news_count = {}
       Commentary.count(:id, :conditions => ["is_news = ? AND commentariable_type = 'Person' AND commentariable_id in (?) AND created_at > ?", true, objects, @range.seconds.ago], :group => "commentariable_id").each {|x| @news_count[x[0]] = x[1]}
#       logger.info @news_count.to_yaml

   elsif object_type == "Bill"

       @blog_count = {}
       Commentary.count(:id, :conditions => ["is_news = ? AND commentariable_type = 'Bill' AND commentariable_id in (?) AND created_at > ?", false, objects, @range.seconds.ago], :group => "commentariable_id").each {|x| @blog_count[x[0]] = x[1]}
       logger.info @blog_count.to_yaml
       @news_count = {}
       Commentary.count(:id, :conditions => ["is_news = ? AND commentariable_type = 'Bill' AND commentariable_id in (?) AND created_at > ?", true, objects, @range.seconds.ago], :group => "commentariable_id").each {|x| @news_count[x[0]] = x[1]}
       logger.info @news_count.to_yaml

   else   
      @blog_count = {}
      @news_count = {}
    end

  end

end
