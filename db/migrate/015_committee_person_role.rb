class CommitteePersonRole < ActiveRecord::Migration
  def self.up
    add_column :committees_people, :role, :string
  end

  def self.down
    remove_column :committees_people, :role, :string
  end
end
