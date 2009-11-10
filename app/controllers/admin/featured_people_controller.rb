class Admin::FeaturedPeopleController < Admin::IndexController
#  cache_sweeper :featured_person_sweeper, :only => [ :destroy, :create, :update ]
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @featured_people = FeaturedPerson.paginate(:all, :per_page => 30, :order => "created_at DESC", :page => params[:page]) 
  end

  def show
    @featured_person = FeaturedPerson.find(params[:id])
  end

  def new
    @featured_person = FeaturedPerson.new
  end

  def create
    @featured_person = FeaturedPerson.new(params[:featured_person])
    if @featured_person.save
      flash[:notice] = 'FeaturedPerson was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @featured_person = FeaturedPerson.find(params[:id])
  end

  def update
    @featured_person = FeaturedPerson.find(params[:id])
    if @featured_person.update_attributes(params[:featured_person])
      flash[:notice] = 'FeaturedPerson was successfully updated.'
      redirect_to :action => 'show', :id => @featured_person
    else
      render :action => 'edit'
    end
  end

  def destroy
    FeaturedPerson.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
