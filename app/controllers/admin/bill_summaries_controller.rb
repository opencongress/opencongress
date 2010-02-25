class Admin::BillSummariesController < Admin::IndexController
  before_filter :can_blog

  def index
    @page_title = "Bill Plain Language Summaries"
  end
  
  def new_bill
    @page_title = 'Add a new bill'
    @bill = Bill.new
  end
  
  def save_new_bill
    @bill = Bill.new(params[:bill])
    @bill.save
    
    title = BillTitle.new(params[:title])
    title.title_type = 'official'
    title.as = 'introduced'
    title.bill = @bill
    title.save
    
    action = Action.new(params[:intro_action])
    action.action_type = 'introduced'
    action.date = Time.at(action.datetime)
    action.bill = @bill
    action.save
    
    @bill.introduced = Time.at(action.datetime)
    @bill.save
  end
  
  def edit
    @page_title = "Bill Summaries"
    @bill = Bill.find_by_ident(params[:id])
    
    unless @bill
      flash[:notice] = "Could not find bill with ID=#{params[:id]}"
      redirect_to :action => 'index'
    end
  end
  
  def update
    @bill = Bill.find_by_ident(params[:id])
    
    @bill.update_attributes(params[:bill])
    @bill.save

    flash[:notice] = "#{@bill.typenumber} has been updated"
    redirect_to :action => 'index'
  end
  
  def addtitle
    if params[:title][:title].blank?
      flash[:error] = "You didn't enter a bill title!"
      redirect_to bill_path(Bill.find_by_id(params[:title][:bill_id]))
      return
    end
    
    bt = BillTitle.find_or_create_by_title_and_bill_id(params[:title][:title], params[:title][:bill_id])
    bt.update_attributes(params[:title])
    redirect_to :controller => 'admin/bill_summaries', :action => 'defaulttitle', 
                :id => Bill.find_by_id(params[:title][:bill_id]).ident
  end
  
  def defaulttitle
    @bill = Bill.find_by_ident(params[:id])
    
    unless @bill
      flash[:notice] = "Could not find bill with ID=#{params[:id]}"
      redirect_to :action => 'index'
    end
  end
  
  def updatedefaulttitle
    @bill = Bill.find_by_ident(params[:id])
    
    if params[:default_title].nil?
      flash[:error] = "You didn't select anything!"
      redirect_to :action => 'defaulttitle', :id => @bill.ident
      return
    end

    # set none of the titles to default
    @bill.bill_titles.each do |t|
      t.is_default = false
      t.save
    end
        
    if params[:default_title][:title_id] == 'none'
      flash[:notice] = "No default title set for bill #{@bill.typenumber}"
    else
      bt = BillTitle.find_by_id(params[:default_title][:title_id])
      
      if bt.nil? || (bt.bill != @bill)
        flash[:error] = "An Internal Error Has Occurred!"
        redirect_to :action => 'defaulttitle', :id => @bill.ident
        return
      end
      
      bt.is_default = true
      bt.save
      
      flash[:notice] = "Default Title Selected."
    end
    
    redirect_to :action => 'defaulttitle', :id => @bill.ident
  end
  
  def session_relations
    @relations = BillRelation.find(:all, :conditions => "relation='session'")
  end
  
  def session_relations_add
    @bill = Bill.find_by_ident(params[:relation][:bill_ident]) unless params[:relation][:bill_ident].blank?
    @related_bill = Bill.find_by_ident(params[:relation][:related_bill_ident]) unless params[:relation][:related_bill_ident].blank?
    
    if @bill and @related_bill
      BillRelation.create(:bill_id => @bill.id, :related_bill_id => @related_bill.id, :relation => 'session')
      flash[:notice] = "Relation created!"
    else
      flash[:error] = "Problem finding one or both of the bills!"
    end
    
    redirect_to :action => 'session_relations'
  end
  
  def session_relations_delete
    @relation = BillRelation.find_by_id(params[:id])
    if @relation
      @relation.destroy
      flash[:notice] = "Relation deleted!"
    else
      flash[:error] = "ERROR: Relation not found!"
    end

    redirect_to :action => 'session_relations'
  end
  
  def toggle_frontpage_hot
    @bill = Bill.find_by_ident(params[:bill_id])
    
    if @bill
      @bill.is_frontpage_hot = !@bill.is_frontpage_hot?
      @bill.save
      
      flash[:notice] = "#{@bill.typenumber} #{@bill.is_frontpage_hot? ? 'added to' : 'removed from'} homepage."
      redirect_to bill_path(@bill)
    else
      flash[:error] = "Bill not found!"
      redirect_to :controller => 'admin/index'
    end
  end
  
end