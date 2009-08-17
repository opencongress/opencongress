class RollCallTotals < ActiveRecord::Migration
  def self.up
    add_column :roll_calls, :ayes, :integer, :default => 0
    add_column :roll_calls, :nays, :integer, :default => 0
    add_column :roll_calls, :abstains, :integer, :default => 0
    add_column :roll_calls, :presents, :integer, :default => 0
    
    execute "UPDATE roll_calls SET ayes=0"
    execute "UPDATE roll_calls SET nays=0"
    execute "UPDATE roll_calls SET abstains=0"
    execute "UPDATE roll_calls SET presents=0"
  end
  
  def self.down
    remove_column :roll_calls, :ayes
    remove_column :roll_calls, :nays
    remove_column :roll_calls, :abstains
    remove_column :roll_calls, :presents
  end
end