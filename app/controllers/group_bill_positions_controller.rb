class GroupBillPositionsController < ApplicationController
  def new
    @page_title = 'Add Bill Position to Group'
    @group = Group.find(params[:group_id])
    
    unless params[:number].blank?
      @search_bills = Bill.where(["number=? AND session=?", params[:number].to_i, Settings.default_congress])
    end
    
    respond_to do |format|
      format.html
      format.js
      format.json  { render :json => @groups }
    end
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
  
  def destroy
    @group = Group.find(params[:group_id])
    position = GroupBillPosition.find(params[:id])
    
    if @group.can_moderate?(current_user) && position.group == @group
      position.destroy
      
      redirect_to group_path(@group), :notice => 'Bill position has been removed.'
    else
      redirect_to group_path(@group), :notice => 'You are not allowed to moderate this group!'      
    end
  end
end
