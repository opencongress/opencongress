class WidgetsController < ApplicationController
  layout 'widgets'

  def bill
    if params[:bill_id] and !params[:bill_id].empty?
      @bill = Bill.find_by_ident(params[:bill_id])
    end

    @hot_bills = ObjectAggregate.popular('Bill', Settings.default_count_time, 10)
    if @hot_bills.empty?
      @hot_bills = Bill.find(:all, :limit => 10)
    end
  end


end
