class MiscDbSpeedups < ActiveRecord::Migration
  def self.up
    # Duplicate indices
    execute "drop index fk_bookmarks_user"
  end

  def self.down
    add_index :bookmarks, ["user_id"], :name => "fk_bookmarks_user"
  end
end
