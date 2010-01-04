class ThunderdomeController < ApplicationController

  def index
    @page_title = '<img src="/images/thunderdome.png" class="noborder" />'    
    @thunderdome = BillBattle.find_by_active(true)
    @first_bill = @thunderdome.first_bill
    @second_bill = @thunderdome.second_bill
  end

end
