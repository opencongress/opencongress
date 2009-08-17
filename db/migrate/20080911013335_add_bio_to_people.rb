class AddBioToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :biography, :text
  end

  def self.down
    remove_column :people, :biography
  end
end
