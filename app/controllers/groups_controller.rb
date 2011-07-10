class GroupsController < ApplicationController
  before_filter :login_required, :except => [ :show, :index ]
  
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
    
    group_columns = Group.column_names.collect do |c| "#{Group.table_name}.#{c}" end.join(",")
    pvs_columns = PvsCategory.column_names.collect do |c| "#{PvsCategory.table_name}.#{c}" end.join(",")

   # @groups = Group.includes(:pvs_category).joins("LEFT OUTER JOIN group_members ON groups.id=group_members.group_id").group("#{group_columns}, #{pvs_columns}").select("groups.*, count(group_members.*) as group_members_count").order(@sort).where(where).all #where("join_type='ANYONE'")
    @groups = Group.find_by_sql(["SELECT groups.*, count(group_members.*) as group_members_count 
                                 FROM groups LEFT OUTER JOIN group_members ON (groups.id=group_members.group_id AND group_members.status != 'BOOTED')
                                 LEFT OUTER JOIN pvs_categories ON groups.pvs_category_id=pvs_categories.id 
                                 WHERE #{where[0]} GROUP BY #{group_columns}, #{pvs_columns} ORDER BY #{@sort}"].concat(where[1..-1]))
    
    respond_to do |format|
      format.html
      format.js
      format.json  { render :json => @groups }
    end
  end
end
