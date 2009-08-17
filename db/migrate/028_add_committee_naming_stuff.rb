class AddCommitteeNamingStuff < ActiveRecord::Migration
  def self.up
    add_column :committees, :people_name, :string
    add_column :committees, :people_subcommittee_name, :string
    add_column :committees, :bill_name, :string
    add_column :committees, :bill_subcommittee_name, :string
    add_index :committees, [:people_name, :people_subcommittee_name]
    add_index :committees, [:bill_name, :bill_subcommittee_name]
  end

  def self.down
    remove_column :committees, :people_name
    remove_column :committees, :people_subcommittee_name
    remove_column :committees, :bill_name
    remove_column :committees, :bill_subcommittee_name
  end
end
