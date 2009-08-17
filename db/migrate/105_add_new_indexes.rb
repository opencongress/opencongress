class AddNewIndexes < ActiveRecord::Migration
  def self.up
    add_index :bookmarks, :bookmarkable_type
    add_index :bookmarks, :bookmarkable_id
    add_index :bookmarks, :user_id
    add_index :users, :login
  end

  def self.down
    remove_index :bookmarks, :bookmarkable_type
    remove_index :bookmarks, :bookmarkable_id
    remove_index :bookmarks, :user_id
    remove_index :users, :login
  end
end
