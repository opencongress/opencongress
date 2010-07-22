class MoneyTrailController < ApplicationController

  def show
    @sector = Sector.find(params[:id])
    @people = @sector.people

    @page_title = @sector.name
    @title_class = 'sort'
    @stats_object = @sector
    
    PageView.create_by_hour(@sector, request)
  end
  
  def by_most_viewed
    @sort = :popular
    
    @sectors = PageView.popular('Sector', DEFAULT_COUNT_TIME)
    
    @page_title = "Most Viewed Industry Sectors"
    @title_class = 'sort'
    @title_desc = SiteText.find_title_desc('industry_index')
    
    @custom_sidebar = Sidebar.find_by_page_and_enabled('industry_index', true)   
    
    render :action => 'index'
  end
  
  def index
    @sort = :all
    
    @sectors = CrpSector.find(:all, :order => "name")
    
    @page_title = "Money in Politics"    
  end

  def interest_group_top_recipients
    @group = CrpInterestGroup.find_by_id(params[:id])
    @bill = params[:bill_id].blank? ? nil : Bill.find_by_id(params[:bill_id])
    
    if @bill
      @top_recipients = @group.top_recipients(@bill.chamber)
      @top_recipients_other = @group.top_recipients(@bill.other_chamber)
    else
      @top_recipients = @group.top_recipients('senate')
      @top_recipients_other = @group.top_recipients('house')
    end

    render :layout => false
  end
  
  def person_sector_list
    sector = Sector.find(params[:id], :include => { :person_sectors => :person })
    @person_sector_list = sector.person_sectors
    @id = sector.id
      
    respond_to do |wants|
      wants.js
      wants.html do
        render :partial => 'person_sector_list', :object => @person_sector_list
      end
    end
  end
end
