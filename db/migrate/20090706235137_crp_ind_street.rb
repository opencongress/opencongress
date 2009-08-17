class CrpIndStreet < ActiveRecord::Migration
  def self.up
    drop_table :crp_contrib_individual_to_candidate
    
    create_table :crp_contrib_individual_to_candidate, :id => false do |t|  
      t.string :cycle, :null => false
      t.string :fec_trans_id, :null => false    
      t.string :fec_contrib_id, :null => true    
      t.string :name, :null => false  
      t.string :recipient_osid, :null => true
      t.string :org, :null => true
      t.string :parent_org, :null => true
      t.string :crp_interest_group_osid, :null => true
      t.date :contrib_date, :null => false
      t.integer :amount, :null => true
      t.string :street, :null => true
      t.string :city, :null => true
      t.string :state, :null => true
      t.string :zip, :null => true
      t.string :recip_code, :null => true
      t.string :contrib_type, :null => true
      t.string :pac_id, :null => true
      t.string :other_pac_id, :null => true
      t.string :gender, :null => true
      t.string :fed_occ_emp, :null => true
      t.string :microfilm, :null => true
      t.string :occ_ef, :null => true
      t.string :emp_ef, :null => true
      t.string :source, :null => true
    end
    add_index :crp_contrib_individual_to_candidate, :recipient_osid
    add_index :crp_contrib_individual_to_candidate, :crp_interest_group_osid
  end

  def self.down
  end
end
