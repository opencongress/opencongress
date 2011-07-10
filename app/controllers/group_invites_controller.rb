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
  def show
    @group = Group.find(params[:group_id])
    @group_invite = GroupInvite.find(params[:id])
    key = params[:key]
    
    redirect_to groups_path and return if (key.blank? or @group_invite.key != key)
  
    invite_user = @group_invite.user || User.find_by_email(@group_invite.email)
    if invite_user
      if @group.can_join?(invite_user)
        membership = @group.group_members.find_or_create_by_user_id(invite_user)
        membership.status = 'MEMBER'
        membership.save
        
        # we could log in the user in (if they're not already) here, but too sketchy from
        # a security standpoint
        redirect_to @group, :notice => "You have now joined #{@group.name}"
      else
        redirect_to groups_path, :notice => "You are not allowed to join #{@group.name}"
      end
      return
    else
      # we just have an email so user has to finish registration
      @user = User.new
      @user.email = @group_invite.email
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group_invite }
    end
  end

  # GET /group_invites/new
  # GET /group_invites/new.xml
  def new
    
    ## SECURITY CHECK!!!!
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
    @group = Group.find(params[:group_id])
    
    ####### SECURITY CHECK!
    to_invite = params[:group_invite][:invite_string].split(/,/)
    to_invite.collect!{ |i| i.chomp.strip }
    
    to_invite.each do |i|
      group_invite = nil
      users = User.where(["login=? or email=?", i, i])
      if users.size == 1
        group_invite = @group.group_invites.create(:user_id => users.first.id, :key => random_key)
      else
        if is_valid_email?(i)
          group_invite = @group.group_invites.create(:email => i, :key => random_key)
        end
      end
      
      GroupMailer.invite_email(group_invite).deliver if group_invite
    end
    
  
    respond_to do |format|
      if true
        format.html { redirect_to(@group, :notice => 'Group invitations were sent successfully!') }
      else
        format.html { render :action => "new" }
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
