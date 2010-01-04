class Admin::ThunderdomeController < ApplicationController

  def index
   @current_bill_battle = BillBattle.find_by_active(true)
     if request.post?
       @first = Bill.find_by_ident(params[:bill_1])
       @second = Bill.find_by_ident(params[:bill_2])
       @current_bill_battle.update_attribute(:active, false) if @current_bill_battle
       @current_bill_battle = BillBattle.create({:first_bill_id => @first.id, :second_bill_id => @second.id, :first_score => 0, :second_score => 0, :active => true, :run_date => Time.new, :created_by => current_user.id})
     end
     
  end
end
