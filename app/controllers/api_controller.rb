class ApiController < ApplicationController

  before_filter :check_key, :except => [:index, :key]
  before_filter :check_format, :except => [:index, :key]
  before_filter :set_pagination, :except => [:index, :key]

#  require 'activesupport'

  def index
    @page_title = "OC API Documentation"
    @api_key = ""
    if logged_in?
      @api_key = current_user.feed_key
    end
    
  end

  def people
     
    seperator = "AND"
    seperator = params[:seperator] if params[:seperator] == "OR"
    conditions = {}
    if params[:last_name]
      conditions[:lastname] = params[:last_name]
    end
    if params[:first_name]
      conditions[:firstname] = params[:first_name]
    end
    if params[:gender]
      case params[:gender]
      when 'M'
        conditions[:gender] = 'M'
      when 'F'
        conditions[:gender] = 'F'
      end
    end
    if params[:osid]
      conditions[:osid] = params[:osid]
    end
    if params[:user_approval_from] && params[:user_approval_to]
      conditions[:user_approval] = params[:user_approval_from].to_f..params[:user_approval_to].to_f
    end
    if params[:bioguideid]
      conditions[:bioguideid] = params[:bioguideid]
    end
    if params[:party]
      conditions[:party] = params[:party]
    end
    if params[:state]
      conditions[:state] = params[:state]
    end
    if params[:title]
      conditions[:title] = params[:title]
    end
    if params[:district]
      conditions[:district] = params[:district]
    end
    if params[:person_id]
      conditions[:id] = params[:person_id]
    end
    
    
    people = Person.paginate(:all, :conditions => conditions, :page => @page, :per_page => @per_page)
    
    do_render(people, {:methods => [:oc_user_comments, :oc_users_tracking, 
                                              :abstains_percentage, :with_party_percentage], 
                                              :include => [:recent_news, :recent_blogs, :person_stats],
                                              :except => ["fti_names"]})

          
  end
#  Person.find_by_most_commentary(type = 'news', person_type = 'rep', num = 5, since = DEFAULT_COUNT_TIME)

  def most_blogged_representatives_this_week
    people = Person.find_by_most_commentary('blog', 'rep', @per_page, DEFAULT_COUNT_TIME)
    do_render(people, {:methods => [:oc_user_comments, :oc_users_tracking], :include => [:recent_news, :recent_blogs]})
  end

  def most_blogged_senators_this_week
    people = Person.find_by_most_commentary('blog', 'sen', @per_page, DEFAULT_COUNT_TIME)
    do_render(people, {:methods => [:oc_user_comments, :oc_users_tracking], :include => [:recent_news, :recent_blogs]})
  end

  def representatives_most_in_the_news_this_week
    people = Person.find_by_most_commentary('news', 'rep', @per_page, DEFAULT_COUNT_TIME)
    do_render(people, {:methods => [:oc_user_comments, :oc_users_tracking], :include => [:recent_news, :recent_blogs]})
  end

  def senators_most_in_the_news_this_week
    people = Person.find_by_most_commentary('news', 'sen', @per_page, DEFAULT_COUNT_TIME)
    do_render(people, {:methods => [:oc_user_comments, :oc_users_tracking], :include => [:recent_news, :recent_blogs]})
  end

  def opencongress_users_tracking_person_are_also_tracking
    @object = Person.find_by_id(params[:id])
    @tracking_suggestions = @object.tracking_suggestions
    render :action => "users_tracking_also_tracking.xml.builder", :layout => false
  end

  def opencongress_users_tracking_bill_are_also_tracking
    @object = Bill.find_by_ident(params[:id])
    @tracking_suggestions = @object.tracking_suggestions
    render :action => "users_tracking_also_tracking.xml.builder", :layout => false
  end
  
  def opencongress_users_supporting_person_are_also
    @object = Person.find_by_id(params[:id])
    @supporting_suggestions = @object.support_suggestions
    case @format
    when "xml"
      render :action => "users_supporting.xml.builder", :layout => false
    else
      render :json => Hash.from_xml(render_to_string(:template => "api/users_supporting.xml.builder", :layout => false)).to_json, :layout => false
    end        
  end

  def opencongress_users_opposing_person_are_also
    @object = Person.find_by_id(params[:id])
    @opposing_suggestions = @object.oppose_suggestions
    case @format
    
    when "xml"
      render :action => "users_opposing.xml.builder", :layout => false
    else
      render :json => Hash.from_xml(render_to_string(:template => "api/users_opposing.xml.builder", :layout => false)).to_json, :layout => false
    end      
  end

  def opencongress_users_supporting_bill_are_also
    @object = Bill.find_by_ident(params[:id])
    @supporting_suggestions = @object.support_suggestions
    case @format
    when "xml"
      render :action => "users_supporting.xml.builder", :layout => false
    else
      render :json => Hash.from_xml(render_to_string(:template => "api/users_supporting.xml.builder", :layout => false)).to_json, :layout => false
    end  
  end

  def opencongress_users_opposing_bill_are_also
    @object = Bill.find_by_ident(params[:id])
    @opposing_suggestions = @object.oppose_suggestions
    case @format
    when "xml"
      render :action => "users_opposing.xml.builder", :layout => false
    else
      render :json => Hash.from_xml(render_to_string(:template => "api/users_opposing.xml.builder", :layout => false)).to_json, :layout => false
    end      
  end

  def opencongress_users_tracking_in_state
    @object = State.find_by_abbreviation(params[:id])
    @tracking_suggestions = @object.tracking_suggestions
    render :action => "users_tracking_also_tracking_location.xml.builder", :layout => false
  end

  def opencongress_users_tracking_in_state_district
    @state = State.find_by_abbreviation(params[:id])
    dis_num = params[:district].to_i
    @object = @state.districts.find_by_district_number(dis_num)
    @object = @state.districts.find_by_district_number(0) unless @object
    @tracking_suggestions = @object.tracking_suggestions
    render :action => "users_tracking_also_tracking_location.xml.builder", :layout => false
  end
  

  def bills
    seperator = "AND"
    seperator = params[:seperator] if params[:seperator] == "OR"
    conditions = {}
    if params[:id]
      conditions[:id] = params[:id]
    end
    if params[:congress]
      conditions[:session] = params[:congress]
    end
    if params[:number]
      conditions[:number] = params[:number]
    end
    if params[:type]
      conditions[:bill_type] = params[:type]
    end
    if params[:sponsor_id]
      conditions[:sponsor] = params[:sponsor_id]
    end
    
    bills = Bill.paginate(:all, :conditions => conditions, :page => @page, :per_page => @per_page)
    
    do_render(bills, {:except => [:rolls, :hot_bill_category_id], 
                                :methods => [:title_full_common, :status], 
                                :include => {:co_sponsors => {:methods => [:oc_user_comments, :oc_users_tracking]}, 
                                             :sponsor => {:methods => [:oc_user_comments, :oc_users_tracking]}, 
                                             :bill_titles => {},
                                             :most_recent_actions => {}

                                             }})
    

  end
  
  def bills_by_ident
    
    these_idents = []
    if params[:ident] && params[:ident].class.to_s == "Array"
      these_idents = params[:ident]
    elsif params[:ident]
      these_idents = params[:ident].split(',')
    end
    
    bills = Bill.find_all_by_ident(these_idents, find_options = {})

    do_render(bills, {:except => [:rolls, :hot_bill_category_id], 
                                :methods => [:title_full_common, :status], 
                                :include => {:co_sponsors => {:methods => [:oc_user_comments, :oc_users_tracking]}, 
                                             :sponsor => {:methods => [:oc_user_comments, :oc_users_tracking]}, 
                                             :bill_titles => {},
                                             :most_recent_actions => {}
                                             }})

  end
  
  def bills_introduced_since
    page = 1
    page = params[:page] unless params[:page].blank?
    date = Time.parse(params[:date]).to_i
    if date
      bills = Bill.paginate(:all, :conditions => ["introduced >= ? ", date], :order => "introduced desc", :page => @page, :per_page => @per_page)


      do_render(bills, {:except => [:rolls, :hot_bill_category_id],
                                :methods => [:title_full_common, :status],
                                :include => {:co_sponsors => {:methods => [:oc_user_comments, :oc_users_tracking]},
                                             :sponsor => {:methods => [:oc_user_comments, :oc_users_tracking]},
                                             :bill_titles => {},
                                             :most_recent_actions => {}
                                             }})
    end
  end
  
  def bills_by_query
    query_stripped = prepare_tsearch_query(params[:q])
    bills = Bill.full_text_search(query_stripped, {:congresses => [DEFAULT_CONGRESS,DEFAULT_CONGRESS - 1,DEFAULT_CONGRESS - 2,DEFAULT_CONGRESS - 3], :page => 1})
    do_render(bills, {:except => [:rolls, :hot_bill_category_id], 
                                :methods => [:title_full_common, :status], 
                                :include => {:co_sponsors => {:methods => [:oc_user_comments, :oc_users_tracking]}, 
                                             :sponsor => {:methods => [:oc_user_comments, :oc_users_tracking]}, 
                                             :bill_titles => {},
                                             :most_recent_actions => {}
                                             }})
  end

  def hot_bills
    bills = Bill.find_hot_bills
    do_render(bills, {:except => [:rolls, :hot_bill_category_id]})
  end
  
  def most_blogged_bills_this_week
    bills = Bill.find_by_most_commentary('blog', 10, DEFAULT_COUNT_TIME)
    do_render(bills, {:except => [:rolls, :hot_bill_category_id]})
  end
  
  def bills_in_the_news_this_week
    bills = Bill.find_by_most_commentary('news', 10, DEFAULT_COUNT_TIME)
    do_render(bills, {:except => [:rolls, :hot_bill_category_id]})
  end
  
  def most_viewed_bills_this_week
    bills = PageView.popular('Bill', DEFAULT_COUNT_TIME + 30.days, 10) || Bill.find(:first)
    do_render(bills, {:except => [:rolls, :hot_bill_category_id]})
  end
  
  def most_tracked_bills_this_week
    order = "desc"
    sort = "bookmark_count_1"
    @range=60*60*24*30
    bills = Bill.find_all_by_most_user_votes_for_range(@range, :order => sort + " " + order, :limit => 20)
    do_render(bills, {:except => [:current_support_pb, :support_count_1, :rolls, :hot_bill_category_id, :support_count_2, :vote_count_2]})
  end

  def most_supported_bills_this_week
    order = "desc"
    sort = "current_support_pb"
    @range=60*60*24*30
    bills = Bill.find_all_by_most_user_votes_for_range(@range, :order => sort + " " + order, :limit => 20)
    do_render(bills, {:except => [:current_support_pb, :support_count_1, :rolls, :hot_bill_category_id, :support_count_2, :vote_count_2]})
  end
  
  def most_opposed_bills_this_week
    order = "desc"
    sort = "support_count_1"
    @range=60*60*24*30
    bills = Bill.find_all_by_most_user_votes_for_range(@range, :order => sort + " " + order, :limit => 20)
    do_render(bills, {:except => [:current_support_pb, :support_count_1, :rolls, :hot_bill_category_id, :support_count_2, :vote_count_2]})
  end
  
  def bill_roll_calls
    bills = Bill.find_all_by_id(params[:bill_id])
    do_render(bills, {:except => [:current_support_pb, :support_count_1, :rolls, :hot_bill_category_id, :support_count_2, :vote_count_2], :include => [:roll_calls]})    
  end
  
  def issues
    conditions = {}
    if params[:issue_id]
      conditions[:id] = params[:issue_id]
    end
    if params[:show_bills].blank?
      issues = Subject.find(:all, :conditions => conditions)
      render :xml => issues.to_xml
    elsif params[:include_recent_actions].blank?
      issues = Subject.find(:all, :conditions => conditions, :include => [:bills])
      render :xml => issues.to_xml(:include => [:bills])
    else      
      issues = Subject.find(:all, :conditions => conditions, :include => {:bills => :most_recent_actions})
      render :xml => issues.to_xml(:include => {:bills => {:include => :most_recent_actions}})
    end
  end

  def issues_by_keyword
    @query = params[:keyword]
    query_stripped = prepare_tsearch_query(@query)
    @issues = Subject.full_text_search(query_stripped, :page => 1)
    render :xml => @issues.to_xml
  end
  
  def bills_by_issue_id
    issues = Subject.find_all_by_id(params[:issue_id])
    render :xml => issues.to_xml(:include => {:recently_introduced_bills => {:methods => :title_common}})
  end    

  def key
  end
  

  private
  def check_key
    unless params[:key].blank?
     u = User.find_by_feed_key(params[:key])
     u.api_hits.create({:action => params[:action]})
expires_in 60.minutes, :public => true
    else
     redirect_to :action => "index"
    end
  end
  
  def check_format
    @format = "xml"
    @format = "json" if params[:format] && params[:format] == "json"
  end

  def set_pagination
    @page = 1
    @page = params[:page] if params[:page]
    @per_page = 30
    @per_page = params[:per_page].to_i if params[:per_page] && params[:per_page].to_i < 30
  end

  def do_render(object, parameters)
#    require 'json/pure' 
#     require 'json/add/rails'
    require 'activesupport'
    case @format
    when 'xml'
      render :xml => object.to_xml(parameters)
    else
      render :json => Hash.from_xml(object.to_xml(parameters)).to_json
    end
    
  end
  
end
