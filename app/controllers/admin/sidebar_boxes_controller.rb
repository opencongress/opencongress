class Admin::SidebarBoxesController < Admin::IndexController
  before_filter :can_blog
  
  # GET /sidebar_boxes
  # GET /sidebar_boxes.xml
  def index
    @sidebar_boxes = SidebarBox.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sidebar_boxes }
    end
  end

  # GET /sidebar_boxes/1
  # GET /sidebar_boxes/1.xml
  def show
    @sidebar_box = SidebarBox.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sidebar_box }
    end
  end

  # GET /sidebar_boxes/new
  # GET /sidebar_boxes/new.xml
  def new
    @sidebar_box = SidebarBox.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sidebar_box }
    end
  end

  # GET /sidebar_boxes/1/edit
  def edit
    unless params[:sidebarable_type].blank? or params[:sidebarable_id].nil?
      @sidebar_box = SidebarBox.find_or_create_by_sidebarable_type_and_sidebarable_id(params[:sidebarable_type], params[:sidebarable_id])
    else
      redirect_to '/admin'
    end
  end

  # POST /sidebar_boxes
  # POST /sidebar_boxes.xml
  def create
    @sidebar_box = SidebarBox.new(params[:sidebar_box])

    respond_to do |format|
      if @sidebar_box.save
        flash[:notice] = 'SidebarBox was successfully created.'
        format.html { redirect_to(@sidebar_box) }
        format.xml  { render :xml => @sidebar_box, :status => :created, :location => @sidebar_box }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sidebar_box.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sidebar_boxes/1
  # PUT /sidebar_boxes/1.xml
  def update
    @sidebar_box = SidebarBox.find(params[:id])

    respond_to do |format|
      if @sidebar_box.update_attributes(params[:sidebar_box])
        flash[:notice] = 'SidebarBox was successfully updated.'
        
        # this redirect will only work for bills now
        format.html { redirect_to(:controller => '/bill',:action => 'show', :id =>  @sidebar_box.sidebarable.ident) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sidebar_box.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sidebar_boxes/1
  # DELETE /sidebar_boxes/1.xml
  def destroy
    @sidebar_box = SidebarBox.find(params[:id])
    @sidebar_box.destroy

    respond_to do |format|
      format.html { redirect_to(sidebar_boxes_url) }
      format.xml  { head :ok }
    end
  end
end
