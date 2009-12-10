class PeopleController < ApplicationController
  include ActionView::Helpers::NumberHelper
  
  verify :method => :post, :only => [:most_viewed_text_update]
  before_filter :page_view, :only => :show
  before_filter :open_secrets_ping, :only => :show
  before_filter :person_profile_shared, :only => [:show, :comments, :bills, :voting_history, :money, :news_blogs, :videos, :news, :blogs]
  skip_before_filter :store_location, :only => [:rate,:atom_top_commentary,:atom_news,:atom_blogs,:atom_topnews,:atom_topblogs,:atom_featured,:atom,:atom_top20]

  
  def index
    @page_title = "Senators and Representatives"
    @breadcrumb = { 
      1 => { 'text' => "People", 'url' => { :controller => 'people'} }
    }
  end

  def send_person
    params.delete(:commit)
    person = Person.find(params[:id])
    email = person.email
    if email
      Emailer::deliver_send_person(email, 'visitor@opencongress.org',
        params[:subject], params[:msg]) if email
      action_done = "Email sent"
    else
      action_done = "Sorry but #{person.name} does not have an email address."
    end

    flash[:notice] = action_done
    respond_to do |wants|
      wants.html do
        # Handle users with javascript disabled
        redirect_to :action => :show, :id => person.id
      end
      wants.js {}
    end
  end

  def people_list
    expires_in 20.minutes, :public => true

    congress = params[:congress] ? params[:congress].to_i : DEFAULT_CONGRESS
    person_type = (params[:person_type] == 'senators') ? 'sen' : 'rep'
    @person_type = (person_type == 'sen') ? :senators : :representatives
    @sort = (params[:sort] || :state).to_sym

    @sort_by = case @sort
      when :name
        'lastname asc'
      when :popular
        'view_count desc'
      when :approval
        'person_approval_average desc'
      else
        'state, lastname'
      end

    if @sort == :popular || @sort == :approval
      @days = days_from_params(params[:days])
    end
    @people = Rails.cache.fetch("people_list_#{ @sort.to_s }_#{ @person_type.to_s }", :expires_in => 20.minutes) {
          Person.list_chamber(person_type, congress, @sort_by)
    }

    if @sort == :popular
      @atom = {'link' => url_for(:only_path => false, :controller => 'people', :action => 'atom_top20', :type => person_type), 'title' => "Top 20 Most Viewed #{@person_type.to_s.capitalize}"}
      @page_title = person_type == 'sen' ? "Most Viewed Senators" : "Most Viewed Representatives"
    else
      @page_title = person_type == 'sen' ? "Senators" : "Representatives"
    end

    @show_tracked_list = true
    @title_desc = SiteText.find_title_desc(person_type == 'sen' ? 'people_senator_list' : 'people_representative_list')
    with_random_news = @people.select{|p| p.news_count.to_i > 0}.rand
    with_random_blogs = @people.select{|p| p.blog_count.to_i > 0}.rand
    random_news, random_blogs = [[nil,nil],[nil,nil]]
    random_news = Person.random_commentary(with_random_news.id, "news", 1, DEFAULT_COUNT_TIME) if with_random_news
    random_blogs = Person.random_commentary(with_random_blogs.id, "blog", 1, DEFAULT_COUNT_TIME) if with_random_blogs

    @carousel = [random_news, random_blogs, @people.sort{|a,b| b.view_count.to_i <=> a.view_count.to_i}[0..9]]
 		
		respond_to do |format| 
      format.html { render :action => 'list' }
      format.js { render :action => 'update'}
		end
  end

  def compare
    @title_class = 'sort compare'
    @page_title = "Head-to-Head Vote Comparison"
    if params[:representatives]
      @peeps = Person.rep.find(:all, :order => "people.lastname ASC")
      @tab_state = "reps_tab"
    else
      @peeps = Person.sen.find(:all, :order => "people.lastname ASC")
      @tab_state = "sens_tab"
    end

    if params[:person1]
    @person1 = Person.find(params[:person1])
    @person2 = Person.find(params[:person2])
    @head_title = " - #{@person1.title} #{@person1.lastname} and #{@person2.title} #{@person2.lastname}"
    @shared_committees = @person1.committees.find(:all, :include => :people, :conditions => ["people.id = ?", @person2.id])

    @vote_together = RollCall.vote_together(@person1, @person2)
    logger.info @vote_together.to_yaml
    @hot_votes = RollCall.find(:all, :select => "DISTINCT roll_calls.id", :include => [:roll_call_votes, :bill],
                  :conditions => ['roll_call_votes.person_id IN (?)
                                   AND is_hot = ?',
                  [@person1.id,@person2.id], true]).sort_by(&:bill_id).group_by(&:bill_id)
    @cold_votes = RollCall.find(:all, :select => "DISTINCT roll_calls.id", :include => [:roll_call_votes, :bill],
                  :conditions => ['roll_call_votes.person_id IN (?)
                                   AND ( question LIKE ? OR question LIKE ? OR question LIKE ? )
                                   AND bills.hot_bill_category_id IS NULL AND ( roll_calls.is_hot IS NULL OR roll_calls.is_hot = ?)',
                  [@person1.id,@person2.id], "On Passage%", "On Motion to Concur in Senate Amendments", "On Concurring %", false]).sort_by(&:bill_id).group_by(&:bill_id)

    end
    
    respond_to do |format|
      format.html {
        
      }
      format.xml {
         expires_in 6.hours, :public => true
      }
      format.json {
        render :json => Hash.from_xml(render_to_string(:template => "people/compare.xml.builder", :layout => false)).to_json, :layout => false
      }
    end

  end
  
  def most_commentary
    @breadcrumb = {
      1 => { 'text' => "People", 'url' => "/people" },
    }
    
    @days = days_from_params(params[:days])
    
    if params[:person_type] == 'representatives'
      person_type = 'rep'     
			@person_type = :representatives
      @page_title = "Representatives Most Written About "
      bc_url = '/people/representatives'
      @breadcrumb[2] = { 'text' => "Representatives", 'url' => bc_url }
      @atom = {
        'link' => "/people/representatives/atom/most/", 
        'title' => "Top 20 Representatives Most Written About "
      }
    else
      person_type = 'sen'
			@person_type = :senators
      @page_title = "Senators Most Written About "
      bc_url = '/people/senators'
      @breadcrumb[2] = { 'text' => "Senators", 'url' => bc_url }
      @atom = {
        'link' => "/people/senators/atom/most/", 
        'title' => "Top 20 Senators Most Written About "
      }
    end
          
    if params[:type] == 'news'
      @commentary_type = 'news'
      @page_title += "In The News"
      @atom['link'] += "news"
      @atom['title'] += "In the News"
      @breadcrumb[3] = { 'text' => "Most In News", 'url' => "#{bc_url}/most/in_news" }
    else
      @commentary_type = 'blog'
      @page_title += "On Blogs"
      @atom['link'] += "blog"
      @atom['title'] += "On Blogs"
      @breadcrumb[3] = { 'text' => "Most In Blogs", 'url' => "#{bc_url}/most/in_news" }
    end
    
    @sort = @commentary_type
    @sortz = :"#{@person_type}_most_#{@commentary_type}"
    @show_article_count = true

    #check for fragment cache here!
    unless read_fragment("person_meta_#{@person_type}_#{@sort}_#{@days}")
      @people = Person.list_chamber(person_type, DEFAULT_CONGRESS, "#{@commentary_type}_count DESC")
    end
    respond_to do |format| 
      format.html { render :action => 'list' }
      format.js { render :action => 'update' }
		end
  end
  
  def atom_top_commentary
    if params[:person_type] == 'representatives'
      person_type = 'rep'
      person_type_atom = 'representatives'
      @xml_title = "Representatives Most Written About "
    else
      person_type = 'sen'
      person_type_atom = 'senators'
      @xml_title = "Senators Most Written About "
    end
          
    if params[:type] == 'news'
      commentary_type = 'news'
      @xml_title += "In The News"
    else
      commentary_type = 'blog'
      @xml_title += "On Blogs"
    end
    
    @self_href = { :controller => "people/#{person_type_atom}/atom/most", :action => commentary_type, :only_path => false }
    @alt_href = { :controller => "people/#{person_type_atom}/most", :action => commentary_type, :only_path => false }
    @atom_path = "/#{person_type}/most/#{commentary_type}"
    
    @date_method = :"entered_top_#{commentary_type}"
    
    @people = Person.top20_commentary(commentary_type, person_type)
    expires_in 60.minutes, :public => true

    render :action => 'top20_atom', :layout => false
  end
  
  
  def show_f
    render :action => :show
  end

  def comments
    @person = Person.find(params[:id], :include => :roles)
    congress = params[:congress] ? params[:congress] : DEFAULT_CONGRESS
    respond_to do |format|
      format.html {
    
        @atom = {'link' => url_for(:only_path => false, :controller => 'people', :action => 'atom', :id => @person), 'title' => "Track " + @person.name}
        @hide_atom = true
        @meta_description = "OpenCongress profile of #{@person.name}"

        comment_redirect(params[:goto_comment]) and return if params[:goto_comment]

      }
    end
  end
  
  def show
    congress = params[:congress] ? params[:congress] : DEFAULT_CONGRESS
    expires_in 20.minutes, :public => true

    respond_to do |format|
     format.html {
		  @abstain_rank = @person.abstain_rank
      
      comment_redirect(params[:goto_comment]) and return if params[:goto_comment]
		  
		  # "issue cloud" code; to be used later
		  #cosponsored_bills = @person.bills_cosponsored
		  #issue_hash = {}
		  #cosponsored_bills.each { |cb| cb.subjects.collect { |i| issue_hash[i] = issue_hash[i].nil? ? 1 : issue_hash[i] + 1}}
		  #@top_issues = issue_hash.to_a.sort { |a, b| b[1] <=> a[1] }[0..20]
		  #@top_issues.sort! {|a,b| a[0].term <=> b[0].term }
		  #logger.warn "TOP ISSUES: #{@top_issues}"
		  
      @br_link = cache.fetch("person_link_#{@person.id}", :expires_in => 20.minutes) {
         @person.br_link
      }
		  
		  @include_vids_styles = true
      
      @featured_person_text = @person.featured_people.first
      @person_tracking_suggestions = @person.tracking_suggestions
      @supporting_suggestions = @person.support_suggestions
      @opposing_suggestions = @person.oppose_suggestions
      @breadcrumb = { 
        1 => { 'text' => "People", 'url' => { :controller => 'people'} },
        2 => { 'text' => @person.name, 'url' => { :controller => 'people', :action => 'show', :id => @person } }
      }
      @atom = {'link' => url_for(:only_path => false, :controller => 'people', :action => 'atom', :id => @person), 'title' => "Track " + @person.name}
 		@hide_atom = true
      }
     format.xml {
        render :xml => @person.to_xml(:include => [:recent_news, :recent_blogs])
     }
   end
    
 end
 
 def money
   @igs = @person.top_interest_groups(25) 
 end
 
 def wiki

    @include_wiki_styles = true

    require 'hpricot'
    require 'open-uri'
    @person = Person.find(params[:id])
    
    @comments = @stats_object = @user_object = @person
    @wiki_tab = true
    tabs
   @page_title_prefix = "U.S. Congress"
   @page_title = @person.title_full_name
   link = @person.wiki_url
   
   @breadcrumb = { 
        1 => { 'text' => "People", 'url' => { :controller => 'people'} },
        2 => { 'text' => @person.name, 'url' => { :controller => 'people', :action => 'show', :id => @person } }
      }
      @atom = {'link' => url_for(:only_path => false, :controller => 'people', :action => 'atom', :id => @person), 'title' => "Track " + @person.name}
            @hide_atom = true
            @meta_description = "OpenCongress profile of #{@person.name}"
    
    doc = Hpricot(open(link))
    if doc
      doc.search("#siteSub").remove
      doc.search("#jump-to-nav").remove
      doc.search("pagetheme").remove
      content = (doc/"#bodyContent").inner_html.gsub(/&lt;pagetheme&gt;(.*)&lt;\/pagetheme&gt;/, '')
      render :inline => content, :layout => "application"
    end
   
 end
 
  def user_stats_ajax
    @person = Person.find(params[:id])
    @supporting_suggestions = @person.support_suggestions
    @opposing_suggestions = @person.oppose_suggestions
    render :action => "user_stats_ajax", :layout => false
  end
 
  def news
    @person = Person.find(params[:id])
    @page = params[:page]
    @page = "1" unless @page
    
    if params[:sort] == 'toprated'
      @sort = 'toprated'
    elsif params[:sort] == 'oldest'
      @sort = 'oldest'
    else
      @sort = 'newest'
    end
    
    if @sort == 'toprated'
      @atom = {'link' => url_for(:only_path => false, :controller => 'people', :id => @person, :action => 'atom_topnews'), 'title' => "#{@person.name} highest rated news articles"}
    else
      @atom = {'link' => url_for(:only_path => false, :controller => 'people', :id => @person, :action => 'atom_news'), 'title' => "#{@person.name} news articles"}
    end
    
    
    ## check if cache fragment exists
    unless read_fragment("#{@person.fragment_cache_key}_news_#{@sort}_page_#{@page}")
      if @sort == 'toprated'
        @news = @person.news.find(:all, :order => 'commentaries.average_rating IS NOT NULL DESC').paginate :page => @page
      elsif @sort == 'oldest'
        @news = @person.news.find(:all, :order => 'commentaries.date ASC').paginate :page => @page
      else
        @news = @person.news.paginate :page => @page
      end
    end
    

    @breadcrumb = { 
      1 => { 'text' => "People", 'url' => { :controller => 'people'} },
      2 => { 'text' => @person.name, 'url' => { :controller => 'people', :action => 'show', :id => @person } },
      3 => { 'text' => "News Articles", 'url' => { :controller => 'people', :action => 'news', :id => @person, :sort => @sort } }
    }
  
    @page_title = "#{@person.full_name} In The News"
    @page_title +=  " (Highest Rated)" if (@sort == 'toprated')
  end

  def blogs
    @person = Person.find(params[:id])
    @page = params[:page]
    @page = "1" unless @page

    if params[:sort] == 'toprated'
      @sort = 'toprated'
    elsif params[:sort] == 'oldest'
      @sort = 'oldest'
    else
      @sort = 'newest'
    end
    
    if @sort == 'toprated'
      @atom = {'link' => url_for(:only_path => false, :controller => 'people', :id => @person, :action => 'atom_topblogs'), 'title' => "#{@person.name} highest rated blog articles"}
    else
      @atom = {'link' => url_for(:only_path => false, :controller => 'people', :id => @person, :action => 'atom_blogs'), 'title' => "#{@person.name} blog articles"}
    end
    
    ## check if cache fragment exists
    unless read_fragment("#{@person.fragment_cache_key}_blogs_#{@sort}_page_#{@page}")
      if @sort == 'toprated'
        @blogs = @person.blogs.find(:all, :order => 'commentaries.average_rating IS NOT NULL DESC').paginate :page => @page
      elsif @sort == 'oldest'
        @blogs = @person.blogs.find(:all, :order => 'commentaries.date ASC').paginate :page => @page
      else
        @blogs = @person.blogs.paginate :page => @page
      end
    end
      

    @breadcrumb = { 
      1 => { 'text' => "People", 'url' => { :controller => 'people'} },
      2 => { 'text' => @person.name, 'url' => { :controller => 'people', :action => 'show', :id => @person } },
      3 => { 'text' => "Blog Articles", 'url' => { :controller => 'people', :action => 'blogs', :id => @person, :sort => @sort  } }
    }
    @page_title = "#{@person.full_name} In The Blogs"
    @page_title +=  " (Highest Rated)" if (@sort == 'toprated')
  end


  def news_blogs
    if params[:sort] == 'toprated'
      @sort = 'toprated'
    elsif params[:sort] == 'oldest'
      @sort = 'oldest'
    else
      @sort = 'newest'
    end
    
    unless read_fragment("#{@person.fragment_cache_key}_news_blogs_#{@sort}")
      if @sort == 'toprated'
        @blogs = @person.blogs.find(:all, :order => 'commentaries.average_rating IS NOT NULL DESC', :limit => 10)               
        @news = @person.news.find(:all, :order => 'commentaries.average_rating IS NOT NULL DESC', :limit => 10)                                                                                  
      elsif @sort == 'oldest'
        @news = @person.news.find(:all, :order => 'commentaries.date ASC', :limit => 10)
        @blogs = @person.blogs.find(:all, :order => 'commentaries.date ASC', :limit => 10)
      else
        @news = @person.news.find(:all, :limit => 10)
        @blogs = @person.blogs.find(:all, :limit => 10)
      end
    end
  end
  
  
  
  def videos
    @include_vids_styles = true
    @person = Person.find(params[:id])
    @page_title = "Videos of #{@person.full_name}"

    @videos = @person.videos.paginate :page => params[:page]
  end
  
  def atom_news
    @person = Person.find(params[:id])
    @commentaries = @person.news.find(:all, :limit => 20)
    @commentary_type = 'news'
    expires_in 60.minutes, :public => true

    render :action => 'commentary_atom', :layout => false
  end

  def atom_blogs
    @person = Person.find(params[:id])
    @commentaries = @person.blogs.find(:all, :limit => 20)
    @commentary_type = 'blog'
    expires_in 60.minutes, :public => true

    render :action => 'commentary_atom', :layout => false
  end
  
  def atom_topnews
    @person = Person.find(params[:id])
    @commentaries = @person.news.find(:all, :conditions => "commentaries.average_rating > 5", :limit => 5)
    @commentary_type = 'topnews'
    expires_in 60.minutes, :public => true

    render :action => 'commentary_atom', :layout => false
  end

  def atom_topblogs
    @person = Person.find(params[:id])
    @commentaries = @person.blogs.find(:all, :conditions => "commentaries.average_rating > 5", :limit => 5)
    @commentary_type = 'topblog'
    expires_in 60.minutes, :public => true

    render :action => 'commentary_atom', :layout => false
  end
  
  def atom_featured
    @featured_people = FeaturedPerson.find(:all, :order => 'created_at DESC', :limit => 20)

    expires_in 60.minutes, :public => true
    render :action => 'featured_atom', :layout => false
  end
  
  def voting_history
    @person = Person.find(params[:id])
    @title_desc = SiteText.find_explain('voting_history')
    
    @page = params[:page]
    @page = "1" unless @page
    
    @q = params[:q]
    unless @q.nil?
      query_stripped = prepare_tsearch_query(@q)
    
      @votes = RollCallVote.paginate_by_sql(
                  ["SELECT roll_call_votes.* FROM roll_call_votes, roll_calls, bills, bill_fulltext
                               WHERE bills.session=? AND
                                     bill_fulltext.fti_names @@ to_tsquery('english', ?) AND
                                     bills.id = bill_fulltext.bill_id AND 
                                     bills.id = roll_calls.bill_id AND
                                     roll_calls.id = roll_call_votes.roll_call_id AND
                                     roll_call_votes.person_id = ?
                               ORDER BY bills.hot_bill_category_id, bills.lastaction DESC", DEFAULT_CONGRESS, query_stripped, @person.id],
                               :per_page => 30, :page => @page)
      @page_title = "Voting History Search: #{@person.name}"                      
    else
      @votes = @person.votes.paginate(:page => @page)
      @page_title = "Voting History: #{@person.name}"
    end
  end
  
  def bills
    @page = params[:page]
    @page = "1" unless @page
    
    @q = params[:q]
    
    unless @q.nil?
      query_stripped = prepare_tsearch_query(@q)
    
      @sponsored_bills = Bill.paginate_by_sql(
                  ["SELECT bills.* FROM bills, bill_fulltext
                               WHERE bills.session=? AND
                                      bill_fulltext.fti_names @@ to_tsquery('english', ?) AND
                                     bills.id = bill_fulltext.bill_id AND 
                                     bills.sponsor_id = ?
                               ORDER BY bills.hot_bill_category_id, bills.lastaction DESC", DEFAULT_CONGRESS, query_stripped, @person.id],
                               :per_page => 30, :page => @page)
                               
       @cosponsored_bills = Bill.paginate_by_sql(
                   ["SELECT bills.* FROM bills, bills_cosponsors, bill_fulltext
                                WHERE bills.session=? AND
                                      bill_fulltext.fti_names @@ to_tsquery('english', ?) AND
                                      bills.id = bill_fulltext.bill_id AND 
                                      bills.id = bills_cosponsors.bill_id AND
                                      bills_cosponsors.person_id=?
                                ORDER BY bills.hot_bill_category_id, bills.lastaction DESC", DEFAULT_CONGRESS, query_stripped, @person.id],
                                :per_page => 30, :page => @page)
      @page_title = "Sponsored Bills Search #{@person.name}"                      
    else
      @sponsored_bills = @person.bills.paginate(:all, :include => [:last_action], :per_page => 50, :page => @page)
      @cosponsored_bills = @person.bills_cosponsored.paginate(:all, :include => [:last_action], :per_page => 50, :page => @page)
    end
    
    @search_text = "<span class='none'>Search Sponsored Bills</span>"
  end
  
  
  def atom
    @person = Person.find(params[:id], :include => :roles)
    
    @items = @person.recent_activity
    
    expires_in 60.minutes, :public => true
    
    render :layout => false
  end
  
  def atom_top20
    @people = Person.top20_viewed(params[:type])
    
    if (params[:type])
      case params[:type]
      when 'sen'
        @xml_title = "Top 20 Most Viewed Senators"
        @self_href = { :controller => 'people', :action => 'atom_top20', :type => 'sen', :only_path => false }
        @alt_href = { :controller => 'people', :action => 'senators', :sort => 'popular', :only_path => false }
        @atom_path = "/rep/most/viewed"
      when 'rep'
        @xml_title = "Top 20 Most Viewed Representatives"
        @self_href = { :controller => 'people', :action => 'atom_top20', :type => 'rep', :only_path => false }
        @alt_href = { :controller => 'people', :action => 'representatives', :sort => 'popular', :only_path => false }
        @atom_path = "/sen/most/viewed"
      end
    else
      @xml_title = "Top 20 Most Viewed Members of Congress"
    end
    @date_method = :entered_top_viewed

    expires_in 60.minutes, :public => true
 
    render :action => 'top20_atom', :layout => false
  end
  
  def zipcodelookup
    @page_title = "Find Your Senators and Representatives"
    @display_zip = params[:zip5]
    @display_zip += "-#{params[:zip4]}" unless params[:zip4].blank?
    
    if !params[:address].blank?
      @senators, @reps = Person.find_current_congresspeople_by_address_and_zipcode(params[:address], params[:zip5])
    else
      @senators, @reps = Person.find_current_congresspeople_by_zipcode(params[:zip5], params[:zip4])
    end
    
    unless @senators and @reps
      flash.now[:notice] = "Your search did not return and members of Congress."
    end
  end

  # Rate your approval of person  
  def rate
    person = Person.find_by_id(params[:id])
    score = current_user.person_approvals.find_or_create_by_person_id(person.id)
    score.rating = params[:value]
    score.save
    if person.person_approvals.length > 5
      person.user_approval = person.person_approvals.average(:rating)
      person.save
    end
    logger.info params.to_yaml
    #render :text => "OK"
    render :update do |page|
      page.replace "approval-container", :partial => 'approval', :locals => {:person => person, :user_approval => score.rating} 
      page.visual_effect :pulsate, "mscoretp#{person.id.to_s}"
      page.visual_effect :pulsate, "person_rating"
     end
  end

  def ranking
    @allowed_rankbys = %w[sponsored_bills cosponsored_bills sponsored_bills_passed cosponsored_bills_passed]
    @person_types = %w[Senators Representatives] 
    
    @rankby = @allowed_rankbys.include?(params[:id]) ? params[:id] : 'sponsored_bills'
    @person_type_display = @person_types.include?(params[:person_type]) ? params[:person_type] : 'Senators'
    @person_type = @person_type_display == 'Senators' ? 'sen' : 'rep'

    @people = Person.find(:all,
                :include => [:roles, :person_stats],
                :conditions => [ "roles.role_type=? AND roles.enddate > ? AND person_stats.#{@rankby}_rank IS NOT NULL",
                                 @person_type,  Date.today ], 
                :order => "#{@rankby}_rank")
    @page_title = "#{@person_type_display} by #{@rankby.humanize.downcase}"
  end
  
  private
  
  def person_profile_shared
    if @person = Person.find(params[:id])
      @page_title_prefix = "U.S. Congress"
      @page_title = (@person.senator? ? 'Senator ' : 'Rep. ') + @person.popular_name + 
                    ", #{State.for_abbrev(@person.state) unless @person.state.blank?}"
      @page_title += " (#{@person.party[0,1]})" unless @person.party.blank?
      @meta_description = "Latest votes, sponsored bills, breaking news and blog coverage, and user community for #{@page_title} on OpenCongress"
      
      @sidebar_stats_object = @user_object = @comments = @topic = @person
      @page = params[:page] ||= 1   
      if @person.has_wiki_link?
        @wiki_url = @person.wiki_url
      else
        #direct to create page for bill?  
      end
      
      u_approval = current_user.person_approvals.find_by_person_id(@person.id) if logged_in?
      @user_approval = u_approval.rating if u_approval
      @user_approval = 5 if @user_approval.nil?
      
      @tabs = [
        ["Overview",{:action => 'show', :id => @person}],
        ["Bio","#{@wiki_url}"],
        ["Bills",{:action => 'bills', :id => @person}],
        ["Votes",{:action => 'voting_history', :id => @person}],
        ["Money Trail",{:action => 'money', :id => @person}],
        ["News <span>(#{number_with_delimiter(@person.news_article_count)})</span> & Blogs <span>(#{number_with_delimiter(@person.blog_article_count)})</span>",{:action => 'news_blogs', :id => @person}],
        ["Videos <span>(#{number_with_delimiter(@person.videos.size)})</span>",{:action => 'videos', :id => @person}],
        ["Comments <span>(#{@person.comments.size})</span>",{:action => 'comments', :id => @person}]
      ]
      @top_comments = @person.comments.find(:all,:include => [:user], :order => "comments.plus_score_count - comments.minus_score_count DESC", :limit => 2)
      @atom = {'link' => url_for(:only_path => false, :controller => 'people', :id => @person, :action => 'atom'), 'title' => "#{@person.popular_name} activity"}
      @bookmarking_image = "/images/photos/thumbs_102/#{@person.id}.png"
    else
      flash[:error] = "Invalid person URL."
      redirect_to :action => 'all'
    end  
        
  end
                             
  
  def can_text
    if !(logged_in? && current_user.user_role.can_manage_text)
      redirect_to :controller => '/admin', :action => 'index'
    end
  end

  
  def open_secrets_ping
    path = "/api/index.php?method=opencongress&cycle=#{CURRENT_OPENSECRETS_CYCLE}&cid=#{@person.osid}&apikey=573ba044995d1dad7746b593629a7246"
    #path = "/api/opencongress/crp_opencongress.php?cycle=#{CURRENT_OPENSECRETS_CYCLE}&cid=#{@person.osid}"
    
    Thread.new {    
      begin
        http = Net::HTTP.new('www.opensecrets.org')
        http.start do |http|
          request = Net::HTTP::Get.new(path, {"User-Agent" => DEFAULT_USERAGENT})
          http.read_timeout = 1
          response = http.request(request)
        end
      rescue TimeoutError
        # expected
      end
    }
  end
  
  def page_view
    @person = Person.find(params[:id])
    
    if @person
      PageView.create_by_hour(@person, request)
    end
  end
end
