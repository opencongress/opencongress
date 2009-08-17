class BulkUpdateCachedStateAndDistrictForUsers < ActiveRecord::Migration
  def self.up
    User.update_cached_districts_and_states
  end

  def self.down
  end
end
