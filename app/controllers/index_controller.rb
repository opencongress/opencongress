class IndexController < ApplicationController
  layout "frontpage"
    
  def index
    unless read_fragment("frontpage_bill_mostviewed")
      @popular_bills = PageView.popular('Bill', DEFAULT_COUNT_TIME, 6) || Bill.find(:first)
    end
    unless read_fragment("frontpage_bill_newest")
      @newest_bills = Bill.find(:all, :order => 'introduced DESC', :limit => 4)
    end
    unless read_fragment("frontpage_issue_mostviewed")
      @popular_issues = PageView.popular('Subject', DEFAULT_COUNT_TIME, 6) || Subject.find(:first)
    end
    unless read_fragment("frontpage_person_topsenators")
      @popular_senators = Person.list_chamber('sen', DEFAULT_CONGRESS, "view_count desc", 6)
    end
    unless read_fragment("frontpage_person_topreps")
      @popular_reps = Person.list_chamber('rep', DEFAULT_CONGRESS, "view_count desc", 6)
    end
    unless read_fragment("frontpage_top_searches")
      @hot_bills = PageView.popular('Bill', DEFAULT_COUNT_TIME, 6, DEFAULT_CONGRESS, true) || Bill.find(:first)
    end
    unless read_fragment("frontpage_featured_senator")    
      @popular_sen_text = FeaturedPerson.senator
    end
    unless read_fragment("frontpage_featured_representative")    
      @popular_rep_text = FeaturedPerson.representative
    end
    
    @sessions = CongressSession.sessions
    
    @index_tabs = [{:title => 'Most-Viewed Bills',
            :partial => 'bill',
            :collection => @popular_bills,
            :id => "bv",
            :link => '/bill/most/viewed',
            :cache => 'frontpage_bill_mostviewed'},
            {:title => 'Newest Bills',
            :partial => 'bill',
            :collection => @newest_bills,
            :id => 'bn',
            :style => 'display: none;',
            :link => '/bill/most/viewed',
            :cache => 'frontpage_bill_newest'},
            {:title => 'Most-Viewed Senators',
            :partial => 'person',
            :collection => @popular_senators,
            :id => 'ps',
            :style => 'display: none;',
            :link => '/people/senators?sort=popular',
            :cache => 'frontpage_person_topsenators'},
            {:title => 'Most-Viewed Reps',
            :partial => 'person',
            :collection => @popular_reps,
            :link => '/people/representatives?sort=popular',
            :style => 'display: none;',
            :id => 'pr',
            :cache => 'frontpage_person_topreps'},
            {:title => 'Most-Viewed Issues',
            :partial => 'issue',
            :collection => @popular_issues,
            :style => 'display: none;',
            :id => 'pis',
            :link => '/issues',
            :cache => 'frontpage_issue_mostviewed'}]
    
  end
  
  def notfound
    render :partial => "index/notfound_page", :layout => 'application', :status => "404"
  end
  
  def about
    redirect_to :controller => 'about'
  end

	def popular
		render :update do |page|
			page.replace_html 'popular', :partial => "index/popular", :locals => {:object => @object}
		end
	end

	def s1796_redirect
	  redirect_to bill_path('111-s1796')
	end

	def senate_health_care_bill_111
	  @page_title = 'Senate Health Care Bill - Health Care Reform'
	  render :layout => 'application'
	end

	def senate_health_care_bill_111
	  @page_title = 'The President\'s Proposal - Health Care Reform'
	end
	
end
