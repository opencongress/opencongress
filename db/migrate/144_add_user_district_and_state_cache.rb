class AddUserDistrictAndStateCache < ActiveRecord::Migration
  def self.up
    add_column :users, :district_cache, :text
    add_column :users, :state_cache, :text
  end

  def self.down
    remove_column :users, :district_cache
    remove_column :users, :state_cache
  end
end
