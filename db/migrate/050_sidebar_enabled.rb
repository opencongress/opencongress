class SidebarEnabled < ActiveRecord::Migration
  def self.up
    add_column :sidebars, :enabled, :boolean, :default => false
  end

  def self.down
    remove_column :sidebars, :enabled
  end
end