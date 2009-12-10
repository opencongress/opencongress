class WatchDogsController < ApplicationController
  # GET /watch_dogs
  # GET /watch_dogs.xml

  before_filter :admin_login_required

  def index
    @watch_dogs = WatchDog.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @watch_dogs }
    end
  end

  # GET /watch_dogs/1
  # GET /watch_dogs/1.xml
  def show
    @watch_dog = WatchDog.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @watch_dog }
    end
  end

  # GET /watch_dogs/new
  # GET /watch_dogs/new.xml
  def new
    @watch_dog = WatchDog.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @watch_dog }
    end
  end

  # GET /watch_dogs/1/edit
  def edit
    @watch_dog = WatchDog.find(params[:id])
  end

  # POST /watch_dogs
  # POST /watch_dogs.xml
  def create
    @watch_dog = WatchDog.new(params[:watch_dog])

    respond_to do |format|
      if @watch_dog.save
        flash[:notice] = 'WatchDog was successfully created.'
        format.html { redirect_to(@watch_dog) }
        format.xml  { render :xml => @watch_dog, :status => :created, :location => @watch_dog }
      else
        format.html { render :action => 'new' }
        format.xml  { render :xml => @watch_dog.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /watch_dogs/1
  # PUT /watch_dogs/1.xml
  def update
    @watch_dog = WatchDog.find(params[:id])

    respond_to do |format|
      if @watch_dog.update_attributes(params[:watch_dog])
        flash[:notice] = 'WatchDog was successfully updated.'
        format.html { redirect_to(@watch_dog) }
        format.xml  { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @watch_dog.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /watch_dogs/1
  # DELETE /watch_dogs/1.xml
  def destroy
    @watch_dog = WatchDog.find(params[:id])
    @watch_dog.destroy

    respond_to do |format|
      format.html { redirect_to(watch_dogs_url) }
      format.xml  { head :ok }
    end
  end
end
