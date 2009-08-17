class BillsUpdated < ActiveRecord::Migration
  def self.up
    add_column :bills, :updated, :datetime
    add_column :amendments, :updated, :datetime
  end
  
  def self.down
    remove_column :bills, :updated
    remove_column :amendments, :updated
  end
end