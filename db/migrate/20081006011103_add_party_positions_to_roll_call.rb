class AddPartyPositionsToRollCall < ActiveRecord::Migration
  def self.up
    add_column :roll_calls, :democratic_position, :boolean
    add_column :roll_calls, :republican_position, :boolean 
    RollCall.find(:all).each do |r|
      r.set_party_lines
    end
  end

  def self.down
    remove_column :roll_calls, :democratic_position
    remove_column :roll_calls, :republican_position
  end
end
