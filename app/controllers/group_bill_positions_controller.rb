class GroupBillPositionsController < ApplicationController
  def new
    @group = Group.find(params[:group_id])
  end
  
  def create
    @group = Group.find(params[:group_id])
    
    if @group.can_post?(current_user)
      @group_bill_position = @group.group_bill_positions.create(params[:group_bill_position])

      redirect_to group_path(@group), :notice => "#{@group_bill_position.bill.typenumber} is now #{@group_bill_position.position}ed by #{@group.name}"
    else
      redirect_to group_path(@group), :error => "You don't have permission to post bill positions to the group!"
    end
  end  
end
