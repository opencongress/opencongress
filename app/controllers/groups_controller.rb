class GroupsController < ApplicationController
  before_filter :login_required, :except => [ :show, :index ]
  
  def new
    @page_title = 'Create a New OpenCongress Group'
    @group = Group.new
    @group.join_type = 'ANYONE'
    @group.invite_type = 'ANYONE'
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
    
    @page_title = "#{@group.name} - MyOC Groups"
  end
  
  def index
    @page_title = 'OpenCongress Groups'
  end
end
