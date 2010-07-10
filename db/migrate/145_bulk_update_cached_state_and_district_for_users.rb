class BulkUpdateCachedStateAndDistrictForUsers < ActiveRecord::Migration
  def self.up
      User.find(:all).each do |u|
        u.update_attribute(:state_cache, u.my_state)
        u.update_attribute(:district_cache, u.my_district)
      end
      User.solr_commit
      User.solr_optimize
  end

  def self.down
  end
end
