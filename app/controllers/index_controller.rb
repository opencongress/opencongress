class IndexController < ApplicationController
  layout "frontpage"
  
  def index
    unless read_fragment("frontpage_rightside")
      @popular_bills = ObjectAggregate.popular('Bill', DEFAULT_COUNT_TIME, 6, DEFAULT_CONGRESS, true)
      
      @index_tabs = [
              {:title => 'Newest Bills',
              :partial => 'bill',
              :collection => Bill.find(:all, :order => 'introduced DESC', :limit => 3),
              :id => 'bn',
              :link => '/bill/most/viewed'},
              {:title => 'Most-Viewed Bills',
              :partial => 'bill',
              :collection => ObjectAggregate.popular('Bill', DEFAULT_COUNT_TIME, 3),
              :id => "bv",
              :link => '/bill/most/viewed',
              :style => 'display: none;'},
              {:title => 'Most-Viewed Senators',
              :partial => 'person',
              :collection => Person.list_chamber('sen', DEFAULT_CONGRESS, "view_count desc", 3),
              :id => 'ps',
              :style => 'display: none;',
              :link => '/people/senators?sort=popular'},
              {:title => 'Most-Viewed Reps',
              :partial => 'person',
              :collection => Person.list_chamber('rep', DEFAULT_CONGRESS, "view_count desc", 3),
              :link => '/people/representatives?sort=popular',
              :style => 'display: none;',
              :id => 'pr'},
              {:title => 'Most-Viewed Issues',
              :partial => 'issue',
              :collection => ObjectAggregate.popular('Subject', DEFAULT_COUNT_TIME, 3),
              :style => 'display: none;',
              :id => 'pis',
              :link => '/issues'}]

    end
    
    unless read_fragment("frontpage_featured_members")
      @popular_sen_text = FeaturedPerson.senator
      @popular_rep_text = FeaturedPerson.representative
    end

    @sessions = CongressSession.sessions

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
	  render :layout => 'application'
	end
	
	def house_reconciliation
	  @page_title = 'Health Care Bill Text - H.R. 4872 - Reconciliation Act of 2010'
	  render :layout => 'application'
	end
	
end
