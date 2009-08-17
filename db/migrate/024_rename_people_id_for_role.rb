class RenamePeopleIdForRole < ActiveRecord::Migration
  def self.up
    rename_column :roles, :people_id, :person_id
  end

  def self.down
    rename_column :roles, :person_id, :people_id
  end
end
