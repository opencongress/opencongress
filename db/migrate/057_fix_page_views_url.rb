class FixPageViewsUrl < ActiveRecord::Migration
  def self.up
    change_column :page_views, :referrer, :text
  end

  def self.down
    change_column :page_views, :referrer, :string
  end
end