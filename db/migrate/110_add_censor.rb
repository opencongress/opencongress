class AddCensor < ActiveRecord::Migration
  def self.up
    add_column :comments, :censored, :boolean, :default => false
  end

  def self.down
    remove_column :comments, :censored
  end
end
