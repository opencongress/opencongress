class PvsCategories < ActiveRecord::Migration
  def self.up
    create_table :pvs_categories do |t|
      t.string :name
      t.integer :pvs_id
    end
    
    add_column :bills, :key_vote_category_id, :integer 
    add_column :amendments, :key_vote_category_id, :integer
    
    HotBillCategory.find(:all).each do |hbc|
      if hbc.name = "Budget, Spending, and Taxes"
        pvsc = PvsCategory.create(:name => "Budget, Spending and Taxes")
      else
        pvsc = PvsCategory.create(:name => hbc.name)
      end
      
      execute "UPDATE bills SET hot_bill_category_id=#{pvsc.id} WHERE hot_bill_category_id=#{hbc.id}"
    end
  end

  def self.down
    drop_table :pvs_categories
    
    remove_column :bills, :key_vote_category_id
    remove_column :amendments, :key_vote_category_id
  end
end
