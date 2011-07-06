class UserFacebook < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_uid, :string 

    add_index :users, :facebook_uid
  end

  def self.down
    remove_column :users, :facebook_uid
  end
end
