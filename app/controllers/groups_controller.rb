class GroupsController < ApplicationController
  before_filter :login_required, :except => [ :show, :index ]
  before_filter :check_membership, :only => :show
  
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
        format.html { redirect_to(new_group_group_invite_path(@group, :new => true), :notice => 'Group was successfully created.') }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def show 
    # we got the @group object in check_membership
    
    @simple_comments = true
    
    @page_title = "#{@group.name} - MyOC Groups"
    
    respond_with(@group) do |format|
      format.xml { redirect_to feed_group_political_notebook_notebook_items_path(@group) }
    end
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
    
    if params[:state]
      @state = State.find_by_abbreviation(params[:state])
      @groups = Group.in_state(@state.id).order("groups.state_id, groups.name ASC")
      @page_title = "OpenCongress Groups in #{@state.name}"
    else
      @groups = Group.visible.order(@sort)
    end
    
    unless params[:q].blank? and params[:pvs_category].blank?
      unless params[:q].blank?
        @groups = @groups.with_name_or_description_containing(params[:q])
      end
      
      unless params[:pvs_category].blank?
        @groups = @groups.in_category(params[:pvs_category])
      end
    end

    @groups = @groups.select("groups.*, coalesce(gm.group_members_count, 0) as group_members_count").joins(%q{LEFT OUTER JOIN (select group_id, count(group_members.*) as group_members_count from group_members where status != 'BOOTED' group by group_id) gm ON (groups.id=gm.group_id)}).includes(:pvs_category)

    respond_with @groups
  end
  
  def edit
    @page_title = "Edit Group Settings"
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

  private
  
  def check_membership
    @group = Group.find(params[:id])
    if @group.nil?
      redirect_to groups_path
      return
    end
    
    if !@group.publicly_visible? or @group.join_type == 'INVITE_ONLY'
      if current_user == :false
        redirect_to groups_path, :notice => "That group is private!"
        return
      else
        return true if @group.user == current_user
        
        membership = @group.group_members.where(["group_members.user_id=?", current_user.id]).first
      
        if membership.nil?
          redirect_to groups_path, :notice => "That group is private!"
          return
        elsif membership.status == 'BOOTED'
          redirect_to groups_path, :notice => "You have been booted from that group."
          return
        end
      end
    end
    
    if current_user == :false
      @last_view = Time.now
    else
      membership = @group.group_members.where(["group_members.user_id=?", current_user.id]).first
      
      if membership.nil?
        @last_view = Time.now
      else
        @last_view = membership.last_view
        membership.last_view = Time.now
        membership.save
      end
    end
  end
end
