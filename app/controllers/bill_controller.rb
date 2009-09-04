class BillController < ApplicationController
  include ActionView::Helpers::NumberHelper
  
  helper :roll_call
	before_filter :page_view, :only => [:show, :text]
  before_filter :get_params, :only => [:index, :all, :popular, :pending, :hot, :most_commentary, :readthebill]
  before_filter :bill_profile_shared, :only => [:show, :comments, :money, :votes, :actions, :amendments, :text, :actions_votes, :news_blogs, :videos, :news, :blogs, :news_blogs]
  before_filter :aavtabs, :only => [:actions, :amendments, :votes, :actions_votes]
  skip_before_filter :store_location, :only => [:bill_vote, :status_text, :bill_vote, :user_stats_ajax,:atom,:atom_blogs,:atom_news,:atom_top20,:atom_top_commentary,:atom_topblogs,:atom_topnews]
  
  TITLE_MAX_LENGTH = 150

  def roll_calls
    @roll_calls = RollCall.find_all_by_bill_id(params[:id])
    render :partial => 'roll_call/roll_calls_summary', :locals => { :rolls => @rolls }
  end

  def send_sponsor
    params.delete(:commit)
    bill = Bill.find(params[:id])
    people = [bill.sponsor] + bill.co_sponsors
    sponsors, no_email = people.partition(&:email)
    sponsors_email = sponsors.map{|s| s.email }
    
    Emailer::deliver_send_sponsors(sponsors_email, 'visitor@opencongress.org',
      params[:subject], params[:msg]) unless sponsors.empty?

    flash[:notice] = email_sent(sponsors, no_email)

    respond_to do |wants|
      wants.html do
        # Handle users with javascript disabled
        redirect_to :action => :show, :id => bill.ident
      end
      wants.js {}
    end
  end
  
  def index
    if params[:sort]
      case params[:sort]
      when 'popular'
        redirect_to :action => :popular
      when 'pending'
        redirect_to :action => :pending
      else
        redirect_to :action => :all        
      end
    else
      redirect_to :action => :all
    end    
  end
  
  def all
    congress = params[:congress] ? params[:congress] : DEFAULT_CONGRESS
    
    # the following is temporary until a better way is figured out!
    unless read_fragment("bill_#{@types}_index")
      @bills = {}
      @bill_counts = {}
      @types_from_params.each do |bill_type|
        @bills[bill_type] = Bill.find_all_by_bill_type_and_session(bill_type, congress, :order => 'lastaction DESC', :limit => 5)
        @bill_counts[bill_type] = Bill.count(:conditions => ['bill_type = ? AND session = ?', bill_type, congress])
      end
    end
    
    @page_title = "#{@types.capitalize} Bills: #{congress}th Congress"
    @title_desc = SiteText.find_title_desc('bill_all')
    @sort = 'all'
    # @custom_sidebar = Sidebar.find_by_page_and_enabled('bill_all', true)
    #@related_bills = PageView.popular('Bill', DEFAULT_COUNT_TIME, 5) unless @custom_sidebar
    respond_to do |format|
      format.html {}
      format.js { render :action => 'update'}
    end
  end

  def popular
    @days = days_from_params(params[:days])
    
    unless read_fragment("bill_meta_popular_#{@days}")
      @bills = PageView.popular('Bill', @days, 100)
    end
    
    @atom = {'link' => url_for(:only_path => false, :controller => 'bill/atom/most', :action => 'viewed'), 'title' => "Top 20 Most Viewed Bills"}
    @page_title = 'Most Frequently Viewed Bills'
    @sort = 'popular'
    @title_desc = SiteText.find_title_desc('bill_popular')
    respond_to do |format|
      format.html {}
      format.js { render :action => 'update'}
    end
  end

  def pending
    @bills = Bill.find(:all, :include => [:bill_titles, :actions], 
                        :conditions => ["actions.datetime > ? AND bills.session = ? AND bills.bill_type IN (?)", 3.months.ago, DEFAULT_CONGRESS, @types_from_params], 
                        :order => "actions.date DESC", :limit => 30)
                        
    @page_title = 'Pending Bills in Congress'
    @sort = 'pending'
    @title_desc = SiteText.find_title_desc('bill_pending')
    respond_to do |format|
      format.html {}
      format.js { render :action => 'update'}
    end
  end

  def hot
    @page_title = "Hot Bills"
    @sort = 'hot'
    @title_desc = SiteText.find_title_desc('bill_hot')
    @types = 'all'
    @hot_bill_categories = HotBillCategory.find(:all, :order => :name)
    respond_to do |format|
      format.html {}
      format.js { render :action => 'update'}
    end
  end
  
  def list_bill_type
    congress = params[:congress] ? params[:congress] : DEFAULT_CONGRESS
    @page = params[:page]
    @page = "1" unless @page
    @bill_type = params[:bill_type]

    unless read_fragment(:controller => "bill", :action => "type", :bill_type => @bill_type, :page => @page)

      @bills = Bill.paginate_all_by_bill_type_and_session(@bill_type, congress, :include => "bill_titles", :order => 'number', :page => @page)

    end 

    respond_to do |format|
      format.html {}
      format.js { render :action => 'update'}
    end
  end

  def most_commentary

    @days = days_from_params(params[:days])
    
    if params[:type] == 'news'
      @sort = @commentary_type = 'news'
      @page_title = 'Bills Most Written About In The News'
      @atom = {'link' => "/bill/atom/most/news", 'title' => @page_title}      
    else
      @sort = @commentary_type = 'blog'
      @page_title = 'Bills Most Written About On Blogs'
      @atom = {'link' => "/bill/atom/most/blog", 'title' => @page_title}
    end
    
    unless read_fragment("bill_meta_most_#{@commentary_type}_#{@days}")
      @bills = Bill.find_by_most_commentary(@commentary_type, 20, @days, DEFAULT_CONGRESS, @types_from_params)
    end
    respond_to do |format|
      format.html {}
      format.js { render :action => 'update'}
    end
  end
  
  def upcoming
    @upcoming_bill = UpcomingBill.find(params[:id])
    @page_title = @upcoming_bill.title
    @comments = @user_object = @upcoming_bill
    respond_to do |format|
      format.html {}
      format.js { render :action => 'update'}
    end
  end
  
  def readthebill
    @show_resolutions = (params[:show_resolutions].blank? || params[:show_resolutions] == 'false') ? false : true
    
    @title_class = 'sort'
    
    case params[:sort]
    when 'rushed'
      @page_title = "Read the Bill - Bills Rushed to Vote"
      @bills = Bill.find_rushed_bills(DEFAULT_CONGRESS, 72.hours.to_i, @show_resolutions).paginate :page => params[:page]
      @atom = {'link' => "/bill/readthebill.rss?show_resolutions=#{@show_resolutions}", 'title' => @page_title}
      @title_desc = SiteText.find_title_desc('bills_rushed')
      @sort = 'rushed'
    when 'rtb_all'
      @page_title = "Read the Bill - All Bills With Vote on Passage"
      @bills = Bill.find_rushed_bills(DEFAULT_CONGRESS, 2.years.to_i, @show_resolutions).paginate :page => params[:page]
      @atom = {'link' => "/bill/readthebill.rss?sort=rtb_all&show_resolutions=#{@show_resolutions}", 'title' => @page_title} 
      @title_desc = SiteText.find_title_desc('bills_rushed_all')
      @sort = 'rtb_all'
    else
      @page_title = "Read the Bill - GPO Text Available to Consideration"
      @bills = Bill.find_gpo_consideration_rushed_bills(DEFAULT_CONGRESS, 2.years.to_i, @show_resolutions).paginate :page => params[:page]
      @atom = {'link' => "/bill/readthebill.rss?sort=gpo&show_resolutions=#{@show_resolutions}", 'title' => @page_title} 
      @title_desc = SiteText.find_title_desc('bills_rushed_gpo')
      @sort = 'gpo'      
    end
    
    respond_to do |format|
      format.html
      format.rss { render :action => "readthebill.rxml" }
      format.js { render :action => 'update'}
    end
  end
    
  def atom
    session, bill_type, number = Bill.ident params[:id]
    @bill = Bill.find_by_session_and_bill_type_and_number session, bill_type, number, :include => :actions
    @posts = []
    expires_in 60.minutes, :private => false

    render :layout => false
  end
  
  def atom_news
    @bill = Bill.find_by_ident(params[:id])
    @commentaries = @bill.news
    @commentary_type = 'news'
    expires_in 60.minutes, :private => false

    render :action => 'commentary_atom', :layout => false
  end

  def atom_blogs
    @bill = Bill.find_by_ident(params[:id])
    @commentaries = @bill.blogs
    @commentary_type = 'blog'
    expires_in 60.minutes, :private => false

    render :action => 'commentary_atom', :layout => false
  end
  
  def atom_topnews
    @bill = Bill.find_by_ident(params[:id])
    @commentaries = @bill.news.find(:all, :conditions => "commentaries.average_rating > 5", :limit => 5)
    @commentary_type = 'topnews'
    expires_in 60.minutes, :private => false

    render :action => 'commentary_atom', :layout => false
  end

  def atom_topblogs
    @bill = Bill.find_by_ident(params[:id])
    @commentaries = @bill.blogs.find(:all, :conditions => "commentaries.average_rating > 5", :limit => 5)
    @commentary_type = 'topblog'
    expires_in 60.minutes, :private => false

    render :action => 'commentary_atom', :layout => false
  end

  def atom_top20
    @bills = Bill.top20_viewed
    @date_method = :entered_top_viewed
    @feed_title = "Top 20 Most Viewed Bills"
    @most_type = "viewed"
    expires_in 60.minutes, :private => false
    
    render :action => 'top20_atom', :layout => false
  end

  def atom_top_commentary
    if params[:type] == 'news'
      @most_type = commentary_type = 'news'
      @feed_title = "Top 20 Bills Most Written About In The News"
    else
      @most_type = commentary_type = 'blog'
      @feed_title = "Top 20 Bills Most Written About Blogs"
    end
    
    @date_method = :"entered_top_#{commentary_type}"
  
    @bills = Bill.top20_commentary(commentary_type)
    expires_in 60.minutes, :private => false

    render :action => 'top20_atom', :layout => false
  end

  
  # this action is to show a non-cached version of 'show'
  def show_f
    show
  end
  
  def comments
    respond_to do |format|
      format.html {
        comment_redirect(params[:goto_comment]) and return if params[:goto_comment]
      }
    end
  end
  
  def show
    respond_to do |format|
      format.html {
        comment_redirect(params[:goto_comment]) and return if params[:goto_comment]
        if ActiveSupport::Cache.lookup_store(:mem_cache_store)
          cache = ActiveSupport::Cache.lookup_store(:mem_cache_store)
          @br_link = cache.fetch("bill_link_#{@bill.id}", :expires_in => 20.minutes) {
            @bill.br_link
          }
        else
          @br_link = @bill.br_link
        end
        @tracking_suggestions = @bill.tracking_suggestions
        @supporting_suggestions = @bill.support_suggestions
        @opposing_suggestions = @bill.oppose_suggestions
     }
      format.xml {
        render :xml => @bill.to_xml(:exclude => [:fti_titles], :include => [:bill_titles,:last_action,:sponsor,:co_sponsors,:actions,:roll_calls])
      }
    end
  end


  def user_stats_ajax
    @bill = Bill.find_by_id(params[:id])
    @tracking_suggestions = @bill.tracking_suggestions
    @supporting_suggestions = @bill.support_suggestions
    @opposing_suggestions = @bill.oppose_suggestions
    render :action => "user_stats_ajax", :layout => false 
  end
  
  def text
    @topic = nil
    @meta_description = "Full bill text of #{@bill.title_full_common} on OpenCongress.org"

    # bill text code
    # build the list of versions
    @versions = @bill.bill_text_versions.find(:all, :conditions => "bill_text_versions.previous_version IS NULL")
    if @versions.empty?
      @bill_text = "We're sorry but OpenCongress does not have the full bill text at this time.  Try at <a href='http://thomas.loc.gov/cgi-bin/query/z?c#{@bill.session}:#{@bill.title_typenumber_only}:'>THOMAS</a>."
      @commented_nodes = []
      return
    end

    @version = @versions.first unless (params[:version].blank? or @versions.first.version != params[:version])

    v = @bill.bill_text_versions.find(:first, :conditions => ["bill_text_versions.previous_version=?", @versions.first.version])
    until v.nil?
      @versions << v
      @version = v unless (params[:version].blank? or v.version != params[:version])
      v = @bill.bill_text_versions.find(:first, :conditions => ["bill_text_versions.previous_version=?", v.version])
    end
    @version = @versions.last if @version.nil?

    @page_title = "Text of #{@bill.title_typenumber_only} as #{@version.pretty_version}"

    @nid = params[:nid].blank? ? nil : params[:nid]     
    @commented_nodes = @version.bill_text_nodes.find(:all, :include => :comments)

    begin
      # open html from file
      path = "#{OC_BILLTEXT_PATH}/#{@bill.session}/#{@bill.bill_type}#{@bill.number}#{@version.version}.gen.html-oc"
      @bill_text = File.open(path).read
    rescue
      @bill_text = "We're sorry but OpenCongress does not have the full bill text at this time.  Try at <a href='http://thomas.loc.gov/cgi-bin/query/z?c#{@bill.session}:#{@bill.title_typenumber_only}:'>THOMAS</a>."
    end
  end
  
  def print_text
    @bill = Bill.find_by_ident(params[:id])
    @bill_text = ""
    version = @bill.bill_text_versions.find(:first, :conditions => ["bill_text_versions.version=?", params[:version]])
    if version
      path = "#{OC_BILLTEXT_PATH}/#{@bill.session}/#{@bill.bill_type}#{@bill.number}#{version.version}.gen.html-oc"
      @bill_text = File.open(path).read
    end
    
    render :layout => false
  end
  
  def actions_votes
    respond_to do |format|
      format.html {
        unless @bill.roll_calls.empty?
          @roll_call = @bill.roll_calls[0]
          @aye_chart = ofc2(210,120, "roll_call/partyvote_piechart_data/#{@roll_call.id}?breakdown_type=#{CGI.escape("+")}&disclaimer_off=true&radius=40")
          @nay_chart = ofc2(210,120, "roll_call/partyvote_piechart_data/#{@roll_call.id}?breakdown_type=-&disclaimer_off=true&radius=40")
          @abstain_chart = ofc2(210,120, "roll_call/partyvote_piechart_data/#{@roll_call.id}?breakdown_type=0&disclaimer_off=true&radius=40")
        end
      }
      format.xml {
        render :xml => @bill.to_xml(:exclude => [:fti_titles], :include => [:bill_titles,:last_action,:sponsor,:co_sponsors,:actions,:roll_calls])
      }
    end
  end
  
  def amendments
    @amendments = @bill.amendments.paginate(:all, :page => @page, :per_page => 10, :order => ["retreived_date DESC"])
  end

  def actions
    @actions = @bill.actions.paginate(:all, :page => @page, :per_page => 10, :order => ["date DESC"])
  end 
  
  def votes
    @roll_calls = @bill.roll_calls.paginate(:all, :page => @page, :per_page => 8, :order => ["date DESC"])
  end

  def comms
    @bill = Bill.find_by_ident(params[:ident])
    @comms = @bill.comments.paginate(:all, :order => ["created_at DESC"])
  end
  
  def wiki
      require 'hpricot'
      require 'mediacloth'
      require 'open-uri'
      wiki_url = "#{WIKI_URL}/api.php?action=query&prop=revisions&titles=Economic_Stimulus_Bill_of_2008&rvprop=timestamp|content&format=xml"
      session, bill_type, number = Bill.ident params[:id]
      if @bill = Bill.find_by_session_and_bill_type_and_number(session, bill_type, number, { :include => [ :bill_titles ]})
         #unwise = %w({ } | \ ^ [ ] `)
         badchar = '|'
         escaped_uri = URI.escape(wiki_url)
         doc = Hpricot.XML(open(escaped_uri))
         logger.info doc.to_yaml
         content = (doc/:api/:query/:pages).first.inner_html
         logger.info content
         @wiki_content = MediaCloth::wiki_to_html(content)
      end
  end

  def status_text
    @bill = Bill.find_by_ident(params[:id])  
    
    render :layout => false
  end
  
  def news_blogs
    if params[:sort] == 'toprated'
      @sort = 'toprated'
    elsif params[:sort] == 'oldest'
      @sort = 'oldest'
    else
      @sort = 'newest'
    end
    
    unless read_fragment("#{@bill.fragment_cache_key}_news_blogs_#{@sort}")
      if @sort == 'toprated'
        @blogs = @bill.blogs.find(:all, :order => 'commentaries.average_rating IS NOT NULL DESC', :limit => 10)               
        @news = @bill.news.find(:all, :order => 'commentaries.average_rating IS NOT NULL DESC', :limit => 10)                                                                                  
      elsif @sort == 'oldest'
        @news = @bill.news.find(:all, :order => 'commentaries.date ASC', :limit => 10)
        @blogs = @bill.blogs.find(:all, :order => 'commentaries.date ASC', :limit => 10)
      else
        @news = @bill.news.find(:all, :limit => 10)
        @blogs = @bill.blogs.find(:all, :limit => 10)
      end
    end
  end
  
  def blogs
    if params[:sort] == 'toprated'
      @sort = 'toprated'
    elsif params[:sort] == 'oldest'
      @sort = 'oldest'
    else
      @sort = 'newest'
    end
    
    unless read_fragment("#{@bill.fragment_cache_key}_blogs_#{@sort}_page_#{@page}")
      if @sort == 'toprated'
        @blogs = @bill.blogs.find(:all, :order => 'commentaries.average_rating IS NOT NULL DESC').paginate :page => @page
      elsif @sort == 'oldest'
        @blogs = @bill.blogs.find(:all, :order => 'commentaries.date ASC').paginate :page => @page
      else
        @blogs = @bill.blogs.paginate :page => @page
      end
    end
    
    @page_title = (@sort == 'toprated') ? "Highest Rated " : ""
    @page_title += "Blog Articles for #{@bill.title_typenumber_only}"
    
    if @sort == 'toprated'
      @atom = {'link' => url_for(:only_path => false, :controller => 'bill', :id => @bill.ident, :action => 'atom_topblogs'), 'title' => "#{@bill.title_typenumber_only} highest rated blog articles"}
    else
      @atom = {'link' => url_for(:only_path => false, :controller => 'bill', :id => @bill.ident, :action => 'atom_blogs'), 'title' => "#{@bill.title_typenumber_only} blog articles"}
    end
  end
  
  def topblogs
    @blogs = @bill.blogs.find(:all, :conditions => "commentaries.average_rating > 5", :limit => 5).paginate :page => @page

    @page_title = "Highest Rated Blog Articles For #{@bill.title_typenumber_only}"
    
    @atom = {'link' => url_for(:only_path => false, :controller => 'bill', :id => @bill.ident, :action => 'atom_topblogs'), 'title' => "#{@bill.title_typenumber_only} blog articles"}
    render :action => 'blogs'
  end
  
  def money
    session, bill_type, number = Bill.ident params[:id]
    if @bill = Bill.find_by_session_and_bill_type_and_number(session, bill_type, number, { :include => [ :bill_titles ]})
      respond_to do |format|
        format.html
      end
    else
      flash[:error] = "Invalid bill URL."
      redirect_to :action => 'all'
    end
  end
  
  def news
    if params[:sort] == 'toprated'
      @sort = 'toprated'
    elsif params[:sort] == 'oldest'
      @sort = 'oldest'
    else
      @sort = 'newest'
    end
    
    unless read_fragment("#{@bill.fragment_cache_key}_news_#{@sort}_page_#{@page}")
      if @sort == 'toprated'
        @news = @bill.news.find(:all, :order => 'commentaries.average_rating IS NOT NULL DESC').paginate :page => @page
      elsif @sort == 'oldest'
        @news = @bill.news.find(:all, :order => 'commentaries.date ASC').paginate :page => @page
      else
        @news = @bill.news.paginate :page => @page
      end
    end
    
    @page_title = (@sort == 'toprated') ? "Highest Rated " : ""
    @page_title += "News Articles for #{@bill.title_typenumber_only}"
   
    if @sort == 'toprated'
      @atom = {'link' => url_for(:only_path => false, :controller => 'bill', :id => @bill.ident, :action => 'atom_topnews'), 'title' => "#{@bill.title_typenumber_only} highest rated news articles"}
    else
      @atom = {'link' => url_for(:only_path => false, :controller => 'bill', :id => @bill.ident, :action => 'atom_news'), 'title' => "#{@bill.title_typenumber_only} news articles"}
    end
  end

  def topnews
    @news = @bill.news.find(:all, :conditions => "commentaries.average_rating > 5", :limit => 5).paginate :page => @page
    @page_title = "Highest Rated Blog Articles For #{@bill.title_typenumber_only}"
    @atom = {'link' => url_for(:only_path => false, :controller => 'bill', :id => @bill.ident, :action => 'atom_topnews'), 'title' => "#{@bill.title_typenumber_only} blog articles"}
    render :action => 'news'
  end
  
  def commentary_search
    @page = params[:page]
    @page = "1" unless @page
    
    @commentary_query = params[:q]
    query_stripped = prepare_tsearch_query(@commentary_query)
    @bill = Bill.find_by_ident(params[:id])
    
    if params[:commentary_type] == 'news'
      @commentary_type = 'news'
      @articles = @bill.news.find(:all, :conditions => ["fti_names @@ to_tsquery('english', ?)", query_stripped]).paginate :page => @page
    else
      @commentary_type = 'blogs'
      @articles = @bill.blogs.find(:all, :conditions => ["fti_names @@ to_tsquery('english', ?)", query_stripped]).paginate :page => @page
    end
    
    @page_title = "Search #{@commentary_type.capitalize} for bill #{@bill.title_typenumber_only}"
  end

  def videos
    @include_vids_styles = true
    @page_title = "Videos of #{@bill.title_typenumber_only}"
    @videos = @bill.videos.paginate :page => params[:page]
  end
  
  def bill_vote
    @bill = Bill.find_by_ident(params[:bill])
    if logged_in?
      @bv = current_user.bill_votes.find_by_bill_id(@bill.id)
      unless @bv
        @bv = current_user.bill_votes.create({:bill_id => @bill.id, :user_id  => current_user.id, :support => (params[:id] == "1" ? 1 : 0) }) unless @bv
      else
        if params[:id] == "1"
           if @bv.support == true
             @bv.destroy
           else
              @bv.support = true
              @bv.save
           end
        else
           if @bv.support == false
              @bv.destroy
           else
              @bv.support = false
              @bv.save
           end
        end
      end

      render :update do |page|
        page.replace_html 'vote_results_' + @bill.id.to_s, :partial => "bill_votes"
        page.replace_html 'users_result', user_bill_result(@bill)
        page.visual_effect :pulsate, 'users_result'
        #page.replace_html 'support_' + @bill.id.to_s, @bill.bill_votes.count(:all, :conditions => "support = 0")
        #page.replace_html 'oppose_' + @bill.id.to_s, @bill.bill_votes.count(:all, :conditions => "support = 1")
        #page.replace_html 'vote_message_' + @bill.id.to_s, :partial => "voted"
        #page.show 'vote_message_' + @bill.id.to_s
        #page.visual_effect :highlight, (@bv.support == 0 ? 'support_' : 'oppose_') + @bill.id.to_s if @bv
        #page.visual_effect :highlight, 'vote_message_' + @bill.id.to_s
      end
    else
      render :update do |page|
        page.replace_html 'vote_message_' + @bill.id.to_s, "You must <a href='/login'>login</a> to vote. No account? <a href='/register'>Register</a> now!"
        page.show 'vote_message_' + @bill.id.to_s
        page.visual_effect :highlight, 'vote_message_' + @bill.id.to_s
      end
    end
  end
  
private
  
  def get_params
    case params[:types]
      when "house"
        @types_from_params = Bill.in_house
        @types = "house"
      when "senate"
        @types_from_params = Bill.in_senate
        @types = "senate"
      else
        @types = "all"
        @types_from_params = Bill.all_types_ordered
      end
      @carousel = [Bill.find_hot_bills('bills.page_views_count desc',{:limit => 12})]
  end
  
  def bill_profile_shared
    session, bill_type, number = Bill.ident params[:id]
    if @bill = Bill.find_by_session_and_bill_type_and_number(session, bill_type, number, { :include => [ :bill_titles ]})
      @page_title_prefix = "U.S. Congress"
      @page_title = @bill.title_typenumber_only
      @head_title = @bill.title_common
      if @bill.plain_language_summary.blank?
        @meta_description = "Official government data, breaking news and blog coverage, public comments and user community for #{@bill.title_full_common}"
      else
        @meta_description = @bill.plain_language_summary
      end
      @meta_keywords = "Congress, #{@bill.sponsor.popular_name}, " + @bill.subjects.find(:all, :order => 'bill_count DESC', :limit => 5).collect{|s| s.term}.join(", ")
      @sidebar_stats_object = @user_object = @comments = @topic = @bill
      @page = params[:page] ||= 1   
      if @bill.has_wiki_link?
        @wiki_url = @bill.wiki_url
      elsif logged_in?
        @wiki_create_url = "#{WIKI_URL}/Special:AddData/Bill?Bill[common_title]=#{CGI::escape(@bill.title_common[0..60])}&Bill[bill_number]=#{@bill.bill_type}#{@bill.number}&Bill[chamber]=#{@bill.is_senate_bill? ? "U.S. Senate" : "U.S.%20House%20of%20Representatives"}&Bill[congress]=#{DEFAULT_CONGRESS}" #prolly should be rewritten as a post handled by a custom sfEditFormPreloadText call?
      else
        
      end
      @tabs = [
        ["Overview",{:action => 'show', :id => @bill.ident}],
        ["Actions <span>(#{number_with_delimiter(@bill.actions.size)})</span> & Votes <span>(#{number_with_delimiter(@bill.roll_calls.size)})</span>",{:action => 'actions_votes', :id => @bill.ident}]
      ]
      @tabs << ["Money Trail",{:action => 'money', :id => @bill.ident}] unless @bill.bill_interest_groups.empty?
      @tabs.concat([
        ["Wiki","#{@wiki_url}"],
        ["News <span>(#{number_with_delimiter(@bill.news.size)})</span> & Blogs <span>(#{number_with_delimiter(@bill.blogs.size)})</span>",{:action => 'news_blogs', :id => @bill.ident}],
        ["Videos <span>(#{number_with_delimiter(@bill.videos.size)})</span>",{:action => 'videos', :id => @bill.ident}],
        ["Comments <span>(#{number_with_delimiter(@comments.comments.size)})</span>",{:action => 'comments', :id => @bill.ident}]
      ])
      @top_comments = @bill.comments.find(:all,:include => [:comment_scores, :user], :order => "comments.average_rating DESC", :limit => 2)
      @bookmarking_image = "/stylesheets/img/bill.png"
      @atom = {'link' => url_for(:only_path => false, :controller => 'bill', :id => @bill.ident, :action => 'atom'), 'title' => "#{@bill.title_typenumber_only} activity"}
    else
      flash[:error] = "Invalid bill URL."
      redirect_to :action => 'all'
    end    
  end
  
  def aavtabs
    @aavtabs = []
    @aavtabs <<  ["Amendments", {:controller => 'bill', :action => 'amendments', :id => @bill.ident}] unless @bill.amendments.empty?
    @aavtabs <<  ["Actions", {:controller => 'bill', :action => 'actions', :id => @bill.ident}] unless @bill.actions.empty?
    @aavtabs << ["Votes", {:controller => 'bill', :action => 'votes', :id => @bill.ident}] unless @bill.roll_calls.empty?

  end
  
  def page_view
    session, bill_type, number = Bill.ident params[:id]
    
    if @bill = Bill.find_by_session_and_bill_type_and_number(session, bill_type, number, { :include => :actions })
      PageView.create_by_hour(@bill, request)
    end
  end
  
  def email_sent(sponsors, no_email)
    if sponsors && sponsors.size > 0
      res = "Email sent to #{sponsors.map(&:name).join(', ')}."
    else
      res = ''
    end
    if no_email
      if no_email.size > 1
        res += no_email.map(&:name).join(', ') + ' have no email address.'
      else
        res += no_email.map(&:name).join(', ') + ' does not have an email address.'
      end
    end
    res
  end

end