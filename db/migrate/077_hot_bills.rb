class HotBills < ActiveRecord::Migration
  def self.up
    create_table :hot_bill_categories do |t| 
      t.column :name, :string
    end
    
    add_column :bills, :hot_bill_category_id, :integer
    
    add_index :bills, :hot_bill_category_id
  end
  
  def self.down
    drop_table :hot_bill_categories
    remove_index :bills, :hot_bill_category_id

    remove_column :bills, :hot_bill_category_id
  end
end