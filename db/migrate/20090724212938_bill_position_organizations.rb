class BillPositionOrganizations < ActiveRecord::Migration
  def self.up
    create_table :bill_position_organizations do |t|  
      t.integer :bill_id, :null => false
      t.integer :maplight_organization_id, :null => false
      t.string :name
      t.string :disposition, :null => true
      t.text :citation, :null => true
    end
    
    remove_column :bill_interest_groups, :citation
  end

  def self.down
    drop_table :bill_position_organizations
    
    add_column :bill_interest_groups, :citation, :text
  end
end
