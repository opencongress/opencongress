class PageviewFields < ActiveRecord::Migration
  def self.up
    add_column :page_views, :ip_address, :string
    add_column :page_views, :referrer, :string
  end

  def self.down
    remove_column :page_views, :ip_address
    remove_column :page_views, :referrer
  end
end