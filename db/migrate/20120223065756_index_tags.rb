class IndexTags < ActiveRecord::Migration
  def self.up
    execute "CREATE INDEX index_lower_tag_names ON tags (lower(name))"
  end

  def self.down
    execute "DROP INDEX index_lower_tag_names"
  end
end
