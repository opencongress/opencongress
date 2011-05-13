class BattleRoyaleController < ApplicationController
 
  before_filter :get_range

  def index
    redirect_to :controller => 'bill', :action => 'hot'
  end

  def senators
    redirect_to :controller => 'people', :action => 'senators'
  end

  def representatives
    redirect_to :controller => 'people', :action => 'representatives'
  end

  def issues
    redirect_to :controller => 'issues', :action => 'index'
  end    

  def show_bill_details
    @bill = Bill.find_by_id(params[:id])
    render :action => 'show_bill_details', :layout => false
  end
end
