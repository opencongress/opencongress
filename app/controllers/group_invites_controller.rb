class GroupInvitesController < ApplicationController
  # GET /group_invites
  # GET /group_invites.xml
  # def index
  #   @group_invites = GroupInvite.all
  # 
  #   respond_to do |format|
  #     format.html # index.html.erb
  #     format.xml  { render :xml => @group_invites }
  #   end
  # end
  # 
  # # GET /group_invites/1
  # # GET /group_invites/1.xml
  # def show
  #   @group_invite = GroupInvite.find(params[:id])
  # 
  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.xml  { render :xml => @group_invite }
  #   end
  # end

  # GET /group_invites/new
  # GET /group_invites/new.xml
  def new
    @group = Group.find(params[:group_id])
    @group_invite = GroupInvite.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group_invite }
    end
  end

  # GET /group_invites/1/edit
  # def edit
  #   @group_invite = GroupInvite.find(params[:id])
  # end
  # 
  # # POST /group_invites
  # # POST /group_invites.xml
  def create
    # do nothing for now
    @group = Group.find(params[:group_id])
    redirect_to(@group, :notice => 'Your invitations have been sent!')
    return
    
    @group_invite = GroupInvite.new(params[:group_invite])
  
    respond_to do |format|
      if @group_invite.save
        format.html { redirect_to(@group_invite, :notice => 'Group invite was successfully created.') }
        format.xml  { render :xml => @group_invite, :status => :created, :location => @group_invite }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group_invite.errors, :status => :unprocessable_entity }
      end
    end
  end
  # 
  # # PUT /group_invites/1
  # # PUT /group_invites/1.xml
  # def update
  #   @group_invite = GroupInvite.find(params[:id])
  # 
  #   respond_to do |format|
  #     if @group_invite.update_attributes(params[:group_invite])
  #       format.html { redirect_to(@group_invite, :notice => 'Group invite was successfully updated.') }
  #       format.xml  { head :ok }
  #     else
  #       format.html { render :action => "edit" }
  #       format.xml  { render :xml => @group_invite.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end
  # 
  # # DELETE /group_invites/1
  # # DELETE /group_invites/1.xml
  # def destroy
  #   @group_invite = GroupInvite.find(params[:id])
  #   @group_invite.destroy
  # 
  #   respond_to do |format|
  #     format.html { redirect_to(group_invites_url) }
  #     format.xml  { head :ok }
  #   end
  # end
end
