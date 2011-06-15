class GroupBillPositionsController < ApplicationController
  def new
    @group = Group.find(params[:group_id])
  end
  
  def create
    @group = Group.find(params[:group_id])
    
    if @group.can_post?(current_user)
      bill = Bill.find_by_id(params[:bill_id])
      
      @group_bill_position = @group.group_bill_positions.create(:bill_id => bill.id, :position => params[:position])

      redirect_to group_path(@group), :notice => "#{bill.typenumber} is now #{@group_bill_position.position}ed by #{@group.name}"
    else
      redirect_to group_path(@group), :error => "You don't have permission to post bill positions to the group!"
    end
  end  
end
