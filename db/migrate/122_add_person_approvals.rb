class AddPersonApprovals < ActiveRecord::Migration
  def self.up
    add_column :people, :user_approval, :float, :default => 5
  end

  def self.down
    remove_column :people, :user_approval
  end
end
