class MorePageViewTypes < ActiveRecord::Migration
  def self.up
    add_column :page_views, :committee_id, :integer
    add_column :page_views, :sector_id, :integer
  end

  def self.down
    remove_column :page_views, :committee_id
    remove_column :page_views, :sector_id
  end
end