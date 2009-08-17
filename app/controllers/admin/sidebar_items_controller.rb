class Admin::SidebarItemsController < Admin::IndexController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @sidebar_items = SidebarItem.paginate(:all, :per_page => 30, :page => params[:page])
  end

  def show
    @sidebar_items = SidebarItem.find(params[:id])
  end

  def manage
    redirect_to :controller => 'sidebars', :action => 'list' unless params[:sidebar_id]
    @sidebar = Sidebar.find(params[:sidebar_id])
    @sidebar_items = @sidebar.sidebar_items
    logger.warn @sidebar_items.inspect
  end
  
  def new
    redirect_to :controller => 'sidebars' unless params[:sidebar_id]
    @sidebar = Sidebar.find(params[:sidebar_id])
    @sidebar_items = SidebarItem.new
  end

  def create
    @sidebar_items = SidebarItem.new(params[:sidebar_items])
    @sidebar = Sidebar.find(params[:sidebar_items][:sidebar_id])
    
    if @sidebar.class_type == 'Bill'
      session, bill_type, number = Bill.ident(params[:sidebar_items][:bill_id])
      bill = Bill.find_by_session_and_bill_type_and_number(session, bill_type, number)
      
      if bill
        @sidebar_items.bill = bill
      else
        flash[:notice] = 'The bill ID you entered is not valid'
        render :action => 'new'
      end
    end
    
    if @sidebar_items.save
      flash[:notice] = 'SidebarItems was successfully created.'
      redirect_to :action => 'manage', :sidebar_id => @sidebar
    else
      render :action => 'new'
    end
  end

  def edit
    @sidebar_items = SidebarItem.find(params[:id])
    @sidebar = @sidebar_items.sidebar
  end

  def update
    @sidebar_items = SidebarItem.find(params[:id])
    if @sidebar_items.update_attributes(params[:sidebar_items])
      flash[:notice] = 'SidebarItems was successfully updated.'
      redirect_to :action => 'manage', :sidebar_id => @sidebar_items.sidebar
    else
      render :action => 'edit'
    end
  end

  def destroy
    sbi = SidebarItem.find(params[:id])
    sb = sbi.sidebar
    sbi.destroy
    
    redirect_to :action => 'manage', :sidebar_id => sb
  end
end
