class AddFlaggedToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :flagged, :boolean, :default => false
  end

  def self.down
    remove_column :comments, :flagged
  end
end
