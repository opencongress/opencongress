class Admin::PvsCategoryMappingsController < Admin::IndexController
  before_filter :can_blog
  
  # GET /pvs_category_mappings
  # GET /pvs_category_mappings.xml
  def index
    @pvs_category_mappings = PvsCategoryMapping.includes(:pvs_category).order('pvs_categories.name ASC').all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pvs_category_mappings }
    end
  end

  # GET /pvs_category_mappings/1
  # GET /pvs_category_mappings/1.xml
  def show
    @pvs_category_mapping = PvsCategoryMapping.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pvs_category_mapping }
    end
  end

  # GET /pvs_category_mappings/new
  # GET /pvs_category_mappings/new.xml
  def new
    @pvs_category_mapping = PvsCategoryMapping.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pvs_category_mapping }
    end
  end

  # GET /pvs_category_mappings/1/edit
  def edit
    @pvs_category_mapping = PvsCategoryMapping.find(params[:id])
  end

  # POST /pvs_category_mappings
  # POST /pvs_category_mappings.xml
  def create
    puts "TYPE: #{params[:pvs_category_mapping][:pvs_category_id].class}"
    if params[:pvs_category_mapping][:pvs_category_mappable_id].kind_of? Numeric
      new_ids = [ params[:pvs_category_mapping][:pvs_category_mappable_id] ]
    elsif params[:pvs_category_mapping][:pvs_category_mappable_id].kind_of? Array
      new_ids = params[:pvs_category_mapping][:pvs_category_mappable_id]
    end
    
    new_ids.each do |id|
      @pvs_category_mapping = PvsCategoryMapping.find_or_create_by_pvs_category_mappable_id_and_pvs_category_mappable_type_and_pvs_category_id(id, params[:pvs_category_mapping][:pvs_category_mappable_type], params[:pvs_category_mapping][:pvs_category_id])
    end
    
    respond_to do |format|
      if @pvs_category_mapping.save
        format.html { redirect_to(admin_pvs_category_mappings_url, :notice => 'Pvs category mapping was successfully created.') }
        format.xml  { render :xml => @pvs_category_mapping, :status => :created, :location => @pvs_category_mapping }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pvs_category_mapping.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pvs_category_mappings/1
  # PUT /pvs_category_mappings/1.xml
  def update
    @pvs_category_mapping = PvsCategoryMapping.find(params[:id])

    respond_to do |format|
      if @pvs_category_mapping.update_attributes(params[:pvs_category_mapping])
        format.html { redirect_to(admin_pvs_category_mappings_url, :notice => 'Pvs category mapping was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pvs_category_mapping.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pvs_category_mappings/1
  # DELETE /pvs_category_mappings/1.xml
  def destroy
    @pvs_category_mapping = PvsCategoryMapping.find(params[:id])
    @pvs_category_mapping.destroy

    respond_to do |format|
      format.html { redirect_to(admin_pvs_category_mappings_url) }
      format.xml  { head :ok }
    end
  end
end
