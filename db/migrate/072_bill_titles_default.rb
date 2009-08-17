class BillTitlesDefault < ActiveRecord::Migration
  def self.up
    add_column :bill_titles, :is_default, :boolean, :default => false
  end
  
  def self.down
    remove_column :bill_titles, :is_default
  end 
end