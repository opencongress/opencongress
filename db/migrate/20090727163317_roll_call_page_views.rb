class RollCallPageViews < ActiveRecord::Migration
  def self.up
    add_column :roll_calls, :page_views_count, :integer
  end

  def self.down
    remove_column :roll_calls, :page_views_count
  end
end
