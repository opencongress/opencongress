class FixAmendment < ActiveRecord::Migration
  def self.up
    remove_column :amendments, :purpose
    remove_column :amendments, :description
    add_column :amendments, :purpose, :text
    add_column :amendments, :description, :text
  end

  def self.down
    remove_column :amendments, :purpose
    remove_column :amendments, :description
    add_column :amendments, :purpose, :string
    add_column :amendments, :description, :string
  end
end
