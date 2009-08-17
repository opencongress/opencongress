class AddOkToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :ok, :boolean
    add_index :comments, :ok
  end

  def self.down
    remove_column :comments, :ok
  end
end
