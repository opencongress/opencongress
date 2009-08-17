class Admin::TagsController < Admin::IndexController   
  def index
    list
    render :action => 'list'
  end

  def list
    @tags = Tagg.paginate(:all, :per_page => 30, :page => params[:page])
  end

  def show
    @tag = Tagg.find(params[:id])
  end

  def new
    @tag = Tagg.new
  end

  def create
    @tag = Tagg.new(params[:tag])
    if @tag.save
      flash[:notice] = 'Tag was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @tag = Tagg.find(params[:id])
  end

  def update
    @tag = Tagg.find(params[:id])
    if @tag.update_attributes(params[:tag])
      flash[:notice] = 'Tag was successfully updated.'
      redirect_to :action => 'show', :id => @tag
    else
      render :action => 'edit'
    end
  end

  def destroy
    Tagg.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
