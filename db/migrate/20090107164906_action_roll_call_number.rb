class ActionRollCallNumber < ActiveRecord::Migration
  def self.up
    add_column :actions, :roll_call_number, :integer
  end

  def self.down
    remove_column :actions, :roll_call_number
  end
end
