class RollCallsFilename < ActiveRecord::Migration
  def self.up
    add_column :roll_calls, :filename, :string
  end

  def self.down
    remove_column :roll_calls, :filename
  end
end