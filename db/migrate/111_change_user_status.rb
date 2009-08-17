class ChangeUserStatus < ActiveRecord::Migration
  def self.up
#    remove_column :users, :status
    add_column :users, :enabled, :boolean, :default => true
  end

  def self.down
    remove_column :users, :active
  end
end
