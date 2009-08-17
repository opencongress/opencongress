class AddRollCallToAction < ActiveRecord::Migration
  def self.up
    add_column :actions, :roll_call_id, :integer
    
    add_index :roll_calls, [ :where, :number, :date ]
  end

  def self.down
    remove_column :actions, :roll_call_id
    
    remove_index :roll_calls, [ :where, :number, :date ]
  end
end
