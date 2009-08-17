class AddIpToComments < ActiveRecord::Migration
  def self.up
   add_column :comments, :ip_address, :string
  end

  def self.down
   remove_column :comments, :ip_address
  end
end
