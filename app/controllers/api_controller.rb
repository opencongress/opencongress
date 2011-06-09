class ApiController < ApplicationController

  with_options :except => [:index, :key] do
    before_filter :check_key
    before_filter :set_default_format
    before_filter :set_pagination

    respond_to :xml, :json
  end

  before_filter :lookup_bill, :only => [:opencongress_users_tracking_bill_are_also_tracking, :opencongress_users_supporting_bill_are_also, :opencongress_users_opposing_bill_are_also]
  before_filter :lookup_person, :only => [:opencongress_users_opposing_person_are_also, :opencongress_users_supporting_person_are_also, :opencongress_users_tracking_person_are_also_tracking]
  before_filter :lookup_state, :only => [:opencongress_users_tracking_in_state, :opencongress_users_tracking_in_state_district]
  

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
    
    parameter_map = {
      :osid => :osid,
      :lastname => :last_name,
      :firstname => :first_name,
      :bioguideid => :bioguideid,
      :party => :party,
      :state => :state,
      :title => :title,
      :district => :district,
      :id => :person_id
    }

    parameter_map.each do |k, v|
      conditions[k] = params[v] if params[v]
    end

    if params[:gender]
      case params[:gender]
      when 'M'
        conditions[:gender] = 'M'
      when 'F'
        conditions[:gender] = 'F'
      end
    end

    if params[:user_approval_from] && params[:user_approval_to]
      conditions[:user_approval] = params[:user_approval_from].to_f..params[:user_approval_to].to_f
    end
    
    people = Person.paginate(:all, :conditions => conditions, :page => @page, :per_page => @per_page)
    
    do_render(people, :methods => [:oc_user_comments, :oc_users_tracking, 
                                              :abstains_percentage, :with_party_percentage], 
                                              :include => [:recent_news, :recent_blogs, :person_stats],
                                              :except => ["fti_names"])

          
  end
#  Person.find_by_most_commentary(type = 'news', person_type = 'rep', num = 5, since = Settings.default_count_time)

  def most_blogged_representatives_this_week
    respond_with Person.find_by_most_commentary('blog', 'rep', @per_page, Settings.default_count_time)
  end

  def most_blogged_senators_this_week
    respond_with Person.find_by_most_commentary('blog', 'sen', @per_page, Settings.default_count_time)
  end

  def representatives_most_in_the_news_this_week
    respond_with Person.find_by_most_commentary('news', 'rep', @per_page, Settings.default_count_time)
  end

  def senators_most_in_the_news_this_week
    respond_with Person.find_by_most_commentary('news', 'sen', @per_page, Settings.default_count_time)
  end

  def opencongress_users_tracking_person_are_also_tracking
    render_via_builder_template("api/users_tracking_also_tracking.xml.builder", @person)
  end

  def opencongress_users_supporting_person_are_also
    render_via_builder_template("api/users_supporting.xml.builder", @person)
  end

  def opencongress_users_opposing_person_are_also
    render_via_builder_template("api/users_opposing.xml.builder", @person)
  end

  def opencongress_users_tracking_bill_are_also_tracking
    render_via_builder_template("api/users_tracking_also_tracking.xml.builder", @bill)
  end
    
  def opencongress_users_supporting_bill_are_also
    render_via_builder_template("api/users_supporting.xml.builder", @bill)
  end

  def opencongress_users_opposing_bill_are_also
    render_via_builder_template("api/users_opposing.xml.builder", @bill)
  end

  def opencongress_users_tracking_in_state
    render_via_builder_template("api/users_tracking_also_tracking_location.xml.builder", @state)
  end

  def opencongress_users_tracking_in_state_district
    dis_num = params[:district].to_i
    @object = @state.districts.find_by_district_number(dis_num)
    @object = @state.districts.find_by_district_number(0) unless @object
    render_via_builder_template("api/users_tracking_also_tracking_location.xml.builder", @object)
  end
  
  def bills
    seperator = "AND"
    seperator = params[:seperator] if params[:seperator] == "OR"
    conditions = {}

    parameter_map = {:id => :id, :session => :congress, :number => :number, :bill_type => :type, :sponsor => :sponsor_id}

    parameter_map.each do |k, v|
      conditions[k] = params[v] if params[v]
    end
    
    @bills = Bill.paginate(:all, :conditions => conditions, :page => @page, :per_page => @per_page)

    do_render(@bills)
  end
  
  def bills_by_ident
    
    these_idents = []
    if params[:ident] && params[:ident].class.to_s == "Array"
      these_idents = params[:ident]
    elsif params[:ident]
      these_idents = params[:ident].split(',')
    end
    
    @bills = Bill.find_all_by_ident(these_idents, find_options = {})

    do_render(@bills, :style => :full)
  end
  
  def bills_introduced_since
    page = 1
    page = params[:page] unless params[:page].blank?
    date = Time.parse(params[:date]).to_i
    if date
      @bills = Bill.paginate(:all, :conditions => ["introduced >= ? ", date], :order => "introduced desc", :page => @page, :per_page => @per_page)

      do_render(@bills, :style => :full)
    end
  end
  
  def bills_by_query
    query_stripped = prepare_tsearch_query(params[:q])
    @bills = Bill.full_text_search(query_stripped, {:congresses => [Settings.default_congress,Settings.default_congress - 1,Settings.default_congress - 2,Settings.default_congress - 3], :page => 1})
    do_render(@bills, :style => :full)
  end

  def hot_bills
    @bills = Bill.find_hot_bills
    do_render(@bills)
  end
  
  def stalled_bills
    original_chamber = (params[:passing_chamber] == 's') ? 's' : 'h'
    session = (AVAILABLE_CONGRESSES.include?(params[:session])) ? params[:session] : Settings.default_congress
    
    @bills = Bill.find_stalled_in_second_chamber(original_chamber, session)
    do_render(@bills)
  end
  
  def most_blogged_bills_this_week
    do_render(Bill.find_by_most_commentary('blog', 10, Settings.default_count_time), :style => :simple)
  end
  
  def bills_in_the_news_this_week
    do_render(Bill.find_by_most_commentary('news', 10, Settings.default_count_time), :style => :simple)
  end
  
  def most_viewed_bills_this_week
    @bills = ObjectAggregate.popular('Bill', Settings.default_count_time + 30.days, 10) || Bill.find(:first)
    do_render(@bills)
  end

  def most_tracked_bills_this_week
    @order = "bookmark_count_1 desc"
    render_bill_aggregates(@order)
  end

  def most_supported_bills_this_week
    @order = "current_support_pb desc"
    render_bill_aggregates(@order)
  end
  
  def most_opposed_bills_this_week
    @order =  "support_count_1 desc"
    render_bill_aggregates(@order)
  end
  
  def bill_roll_calls
    bills = Bill.find_all_by_id(params[:bill_id])
    do_render(bills, :except => [:current_support_pb, :support_count_1, :rolls, :hot_bill_category_id, :support_count_2, :vote_count_2], :include => [:roll_calls])    
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
     redirect_to :action => 'index'
    end
  end

  def set_default_format
    # If we default this in the routes file, it will unfortunately 
    # disallow the format to be set via :action(.:format) AS WELL AS via a format= param
    # And we need to allow a format= param for backwards compatibility.

    request.format = :xml unless [:xml, :json].include?(request.format.to_sym)
  end

  def set_pagination
    @page = 1
    @page = params[:page] if params[:page]
    @per_page = 30
    @per_page = params[:per_page].to_i if params[:per_page] && params[:per_page].to_i < 30
  end

  def lookup_bill
    @bill = Bill.find_by_ident(params[:id])
  end

  def lookup_person
    @person = Person.find_by_id(params[:id])
  end
  
  def lookup_state
    @state = State.find_by_abbreviation(params[:id])
  end

  def render_bill_aggregates(order)
    @range = 60*60*24*30
    @bills = Bill.find_all_by_most_user_votes_for_range(@range, :order => order, :limit => 20)

    do_render(@bills, :except => [:current_support_pb, :support_count_1, :rolls, :hot_bill_category_id, :support_count_2, :vote_count_2])
  end

  def render_via_builder_template(template_name, obj)
    respond_with do |format|
      format.xml { render template_name, :locals => {:obj => obj} }
      format.json { render :json => Hash.from_xml(render_to_string(template_name, :locals => {:obj => obj}, :layout => false)).to_json }
    end      
  end

  def do_render(object, parameters = {})
    respond_with object do |format|
      format.any(:xml, :json) { render request.format.to_sym => object.try(:"to_#{request.format.to_sym}", parameters) }
    end
  end
  
end
