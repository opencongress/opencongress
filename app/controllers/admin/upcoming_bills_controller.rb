class Admin::UpcomingBillsController < Admin::IndexController
  before_filter :can_blog

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @upcoming_bills = UpcomingBill.paginate(:all, :per_page => 30, :page => params[:page])
  end

  def show
    @upcoming_bill = UpcomingBill.find(params[:id])
  end

  def new
    @upcoming_bill = UpcomingBill.new
  end

  def create
    @upcoming_bill = UpcomingBill.new(params[:upcoming_bill])
    if @upcoming_bill.save
      flash[:notice] = 'UpcomingBill was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @upcoming_bill = UpcomingBill.find(params[:id])
  end

  def update
    @upcoming_bill = UpcomingBill.find(params[:id])
    if @upcoming_bill.update_attributes(params[:upcoming_bill])
      flash[:notice] = 'UpcomingBill was successfully updated.'
      redirect_to :controller => 'bill', :action => 'upcoming', :id => @upcoming_bill
    else
      render :action => 'edit'
    end
  end

  def destroy
    UpcomingBill.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
