class GroupMembersController < ApplicationController
  def index
    @group = Group.find(params[:group_id])
    
    if @group.can_moderate?(current_user)
      @group_members = @group.group_members.includes(:user).order("users.login")
    else
      @group_members = @group.group_members.where("group_members.status != 'BOOTED'").includes(:user).order("UPPER(users.login)")
    end
  end
  
  def update
    @group = Group.find(params[:group_id])
    
    if (params[:status] == 'MODERATOR' and @group.is_owner?(current_user)) or
       (params[:status] != 'MODERATOR' and @group.can_moderate?(current_user))
      @group_member = GroupMember.find(params[:id])
      @group_member.status = params[:status]
      @group_member.save
      
      redirect_to group_group_members_path(@group), :notice => 'Membership has been updated.'
    else
      redirect_to @group, :error => 'You are not allowed to moderate this group!'
    end
  end
end
