class Admin::TalkingPointsController < Admin::IndexController
  # GET /talking_points
  # GET /talking_points.xml
  def index
    @bill = Bill.find_by_ident(params[:bill_id])

    @talking_points = @bill.talking_points

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @talking_points }
    end
  end

  # GET /talking_points/1
  # GET /talking_points/1.xml
  def show
    @talking_point = TalkingPoint.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @talking_point }
    end
  end

  # GET /talking_points/new
  # GET /talking_points/new.xml
  def new
    @talking_point = TalkingPoint.new

    @bill = Bill.find_by_ident(params[:bill_id])
    @talking_point.talking_pointable = @bill
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @talking_point }
    end
  end

  # GET /talking_points/1/edit
  def edit
    @talking_point = TalkingPoint.find(params[:id])
  end

  # POST /talking_points
  # POST /talking_points.xml
  def create
    @talking_point = TalkingPoint.new(params[:talking_point])

    respond_to do |format|
      if @talking_point.save
        format.html { redirect_to(:action => 'index', :bill_id => @talking_point.talking_pointable.ident, :notice => 'Talking point was successfully created.') }
        format.xml  { render :xml => @talking_point, :status => :created, :location => @talking_point }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @talking_point.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /talking_points/1
  # PUT /talking_points/1.xml
  def update
    @talking_point = TalkingPoint.find(params[:id])

    respond_to do |format|
      if @talking_point.update_attributes(params[:talking_point])
        format.html { redirect_to(:action => 'index', :bill_id => @talking_point.talking_pointable.ident, :notice => 'Talking point was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @talking_point.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /talking_points/1
  # DELETE /talking_points/1.xml
  def destroy
    @talking_point = TalkingPoint.find(params[:id])
    
    @bill = @talking_point.talking_pointable
    
    @talking_point.destroy

    respond_to do |format|
      format.html { redirect_to(:action => 'index', :bill_id => @bill.ident) }
      format.xml  { head :ok }
    end
  end
end
