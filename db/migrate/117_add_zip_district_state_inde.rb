class AddZipDistrictStateInde < ActiveRecord::Migration
  def self.up
   add_index :zipcode_districts, :state
   add_index :users, :zipcode
   add_index :users, :zip_four
  end

  def self.down
   remove_index :zipcode_districts, :state
   remove_index :users, :zipcode
   remove_index :users, :zip_four
  end
end
