class AddUserMyRep < ActiveRecord::Migration
  def self.up
    add_column :users, :representative_id, :integer
    add_column :users, :zip_four, :integer
  end

  def self.down
    remove_column :users, :representative_id
    remove_column :users, :zip_four
  end
end
