class SolrRebuild < ActiveRecord::Migration
  def self.up
     puts "Rebuilding Solr...."
     User.rebuild_solr_index(300)
  end

  def self.down
  end
end
