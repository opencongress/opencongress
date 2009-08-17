class AddUserPictureFields < ActiveRecord::Migration
  def self.up
   add_column :users, :main_picture, :string
   add_column :users, :small_picture, :string
  end

  def self.down
   remove_column :users, :main_picture
   remove_column :users, :small_picture
  end
end
