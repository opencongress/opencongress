class ActivityController < ApplicationController

  def latest
    actions = Action.find(:all, :limit => 24, :order => 'datetime DESC',
      :conditions => ["datetime > ?", Time.new.months_ago(3)])
    
    # The classification groups actions by date non-linearly
    # to present them in the most desirable fashion.
    @actions = Action::classify_by_date(actions)
  end
end
