class RebuildSolrForUsersInDistrictAndState < ActiveRecord::Migration
  def self.up
    User.rebuild_solr_index(300)
  end

  def self.down
  end
end
