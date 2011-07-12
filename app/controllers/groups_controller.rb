class GroupsController < ApplicationController
  before_filter :login_required, :except => [ :show, :index ]
  respond_to :html, :json, :xml
  respond_to :js, :only => [:index]
  
  def new
    @page_title = 'Create a New OpenCongress Group'
    @group = Group.new
    @group.join_type = 'ANYONE'
    @group.invite_type = 'ANYONE'
    @group.post_type = 'ANYONE'
  end
  
  def create
    @group = Group.new(params[:group])
    @group.user = current_user
    
    respond_to do |format|
      if @group.save
        format.html { redirect_to(new_group_group_invite_path(@group), :notice => 'Group was successfully created.') }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def show
    @group = Group.find(params[:id])
    
    @simple_comments = true
    
    @page_title = "#{@group.name} - MyOC Groups"
    
    respond_with @group
  end
  
  def index
    @page_title = 'OpenCongress Groups'

    unless params[:sort].blank?
      sort_column, sort_dir = params[:sort].split
      
      sort_dir = (sort_dir == 'DESC') ? 'DESC' : 'ASC'
      case sort_column
      when 'name'
        @sort = "groups.name #{sort_dir}"
      when 'pvs_category'
        @sort = "pvs_categories.name #{sort_dir}, groups.name ASC"
      when 'group_members'
        @sort = "group_members_count #{sort_dir}"
      else
        @sort = "groups.name #{sort_dir}"
      end
    else
      @sort = 'groups.name ASC'
    end
    
    where = ["groups.publicly_visible='t'"]
    unless params[:q].blank? and params[:pvs_category].blank?      
      unless params[:q].blank?
        where[0] += " AND (groups.name ILIKE ? OR groups.description ILIKE ?)"
        where << "%#{params[:q]}%"
        where << "%#{params[:q]}%"
      end
      
      unless params[:pvs_category].blank?
        where[0] += " AND groups.pvs_category_id=?"
        where << params[:pvs_category]
      end
    end
    
    @groups = Group.select("groups.*, gm.group_members_count").joins(%q{LEFT OUTER JOIN (select group_id, count(group_members.*) as group_members_count from group_members where status != 'BOOTED' group by group_id) gm ON (groups.id=gm.group_id)}).includes(:pvs_category).order(@sort).where([where[0], where[1..-1]])
  
    respond_with @groups
  end
  
  def edit
    @group = Group.find(params[:id])
    
    unless @group.user == current_user
      redirect_to groups_path, :notice => "You are not that group's owner, so you can't edit settings!"
      return
    end
  end
  
  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to(@group, :notice => 'Group settings were successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

end
