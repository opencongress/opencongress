class FixSchema3 < ActiveRecord::Migration
  def self.up
    rename_column :people, :religon, :religion
    rename_column :roles, :type, :role_type
  end

  def self.down
    rename_column :people, :religion, :religon
    rename_column :roles, :role_type, :type
  end
end
