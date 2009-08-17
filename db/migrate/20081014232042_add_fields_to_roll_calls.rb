class AddFieldsToRollCalls < ActiveRecord::Migration
  def self.up
    add_column :roll_calls, :is_hot, :boolean, :default => false
    add_column :roll_calls, :title, :string
    add_column :roll_calls, :hot_date, :datetime
  end

  def self.down
    remove_column :roll_calls, :is_hot
    remove_column :roll_calls, :title
    remove_column :roll_calls, :hot_date
  end
end
