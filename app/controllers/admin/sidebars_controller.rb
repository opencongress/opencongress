class Admin::SidebarsController < Admin::IndexController
  before_filter :can_text
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @sidebars = Sidebar.paginate(:all, :per_page => 30, :page => params[:page])
  end

  def show
    @sidebar = Sidebar.find(params[:id])
  end

  def new
    @sidebar = Sidebar.new
  end

  def create
    @sidebar = Sidebar.new(params[:sidebar])
    if @sidebar.save
      flash[:notice] = 'Sidebar was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @sidebar = Sidebar.find(params[:id])
  end

  def update
    @sidebar = Sidebar.find(params[:id])
    if @sidebar.update_attributes(params[:sidebar])
      flash[:notice] = 'Sidebar was successfully updated.'
      redirect_to :action => 'show', :id => @sidebar
    else
      render :action => 'edit'
    end
  end

  def destroy
    Sidebar.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
