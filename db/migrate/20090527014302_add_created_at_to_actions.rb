class AddCreatedAtToActions < ActiveRecord::Migration
  def self.up
    add_column :actions, :created_at, :datetime
  end

  def self.down
    remove_column :actions, :created_at
  end
end
