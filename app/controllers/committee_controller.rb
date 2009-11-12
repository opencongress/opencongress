class CommitteeController < ApplicationController

  def index
    all = Committee.find(:all, :conditions => ['active = ?', true]).sort_by { |c| [(c.name || ""), (c.subcommittee_name || "") ] }
    @committees = all.group_by {|c| c.name || ""}
    @house_committees = Committee.by_chamber('house').sort_by { |c| [c.name, (c.subcommittee_name || "")] }.group_by(&:name)
    @senate_committees = Committee.by_chamber('senate').sort_by { |c| [c.name, (c.subcommittee_name || "")] }.group_by(&:name)

    #@custom_sidebar = Sidebar.find_by_page_and_enabled('committee_index', true)
    @carousel = PageView.popular('Committee', DEFAULT_COUNT_TIME).slice(0..7)
    
    @page_title =  "Committees"
    @title_class = "sort"
    @title_desc = SiteText.find_title_desc('committee_index')
    
    @breadcrumb = { 
      1 => { 'text' => "Committees", 'url' => { :controller => 'committee'} }
    }
  end

  def show
    @committee = Committee.find(params[:id], :include => :reports)

    if @committee.has_wiki_link? # && RAILS_ENV != "production"
      @wiki_tab = true
      @wiki_url = @committee.wiki_url
    end
    
    @main = Committee.find_by_name_and_subcommittee_name(@committee.name, nil)
    unless @main
      redirect_to :action => 'nodata' 
      return
    end
    @reports = @committee.reports.sort_by { |r| r.index }.reverse.first(5)
    @chair = @committee.chair
    @ranking_member = @committee.ranking_member
    @vice_chair = @committee.vice_chair
 
    @bills_sponsored = @committee.bills_sponsored(5)
 	 	@title_class = "tabs"
 	 	@page_title_prefix = "U.S. Congress"
    @page_title = @committee.main_committee_name 
		@stats_object = @user_object = @comments = @committee
    
		@top_comments = @committee.comments.find(:all,:include => [:comment_scores, :user], :order => "comments.average_rating DESC", :limit => 2)
    
    PageView.create_by_hour(@committee, request)
    @atom = {'link' => url_for(:only_path => false, :controller => 'committee', :id => @committee, :action => 'atom'), 'title' => "#{@committee.name} - Major Bill Actions"}
  end

  def by_chamber
    if params[:chamber] == 'house'
      @chamber = @sort = :house
      @page_title = "House Committees"
    else
      @chamber = @sort = :senate
      @page_title = "Senate Committees"
    end

    @committees = Committee.by_chamber(@chamber).sort_by { |c| [c.name, (c.subcommittee_name || "")] }.group_by(&:name)
    @major = @committees.keys.sort
    
    @custom_sidebar = Sidebar.find_by_page_and_enabled('committee_by_chamber', true)
    @related_committees = PageView.popular('Committee', DEFAULT_COUNT_TIME).slice(0..2) unless @custom_sidebar 
    
    @title_class = "sort"
    @title_desc = SiteText.find_title_desc('committee_index')
    
    @breadcrumb = { 
      1 => { 'text' => "Committees", 'url' => { :controller => 'committee'} },
      2 => { 'text' => @page_title, 'url' => { :controller => 'committee', :action => 'by_chamber', :id => @chamber } }
    }
  end

  def by_most_viewed
    @sort = 'popular'

    @days = days_from_params(params[:days])

    @committees = PageView.popular('Committee', @days)
    
    @custom_sidebar = Sidebar.find_by_page_and_enabled('committee_by_chamber', true)
    
    @atom = {'link' => url_for(:only_path => false, :controller => 'committee', :action => 'atom_top20'), 'title' => "Top 20 Most Viewed Committees"}
    
    @page_title = "Most Viewed Committees"
    @title_class = "sort"
    @title_desc = SiteText.find_title_desc('committee_index')
    
    @breadcrumb = { 
      1 => { 'text' => "Committees", 'url' => { :controller => 'committee'} },
      2 => { 'text' => "Most Viewed", 'url' => { :controller => 'committee', :action => 'by_most_viewed'} }
    }
  end
  
  def report
    #This way things show up in our logs.
    redirect_to CommitteeReport.find(params[:id]).thomas_url
  end

  def atom
    @committee = Committee.find(params[:id])
    
    @committee_name = @committee.subcommittee_name ? @committee.subcommittee_name : @committee.name
    @actions = @committee.latest_major_actions(20)
    expires_in 60.minutes, :public => true

    render :layout => false
  end
  
  def atom_top20
    @comms = Committee.top20_viewed
    expires_in 60.minutes, :public => true

    render :action => 'top20_atom', :layout => false
  end
  
  def nodata
    @page_title = "Committee Data Forthcoming"
    
    @breadcrumb = { 
      1 => { 'text' => "Committees", 'url' => { :controller => 'committee'} }
    }
  end
end
