class AddIndexesOnComments < ActiveRecord::Migration
  def self.up
   add_index :comments, :commentable_id
   add_index :comments, :commentable_type
   add_index :comments, :parent_id
  end

  def self.down
   remove_index :comments, :commentable_id
   remove_index :comments, :commentable_type
   remove_index :comments, :parent_id
  end
end
