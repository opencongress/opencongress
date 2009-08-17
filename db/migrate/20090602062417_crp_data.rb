class CrpData < ActiveRecord::Migration
  def self.up
     # remove old CRP data tables
     drop_table :people_sectors
     drop_table :sectors
     drop_table :contributors
     
     # create new, more awesome tables
     create_table :crp_sectors do |t|      
       t.string :name, :null => false
       t.string :display_name, :null => true
     end
     
     create_table :crp_industries do |t|      
       t.string :name, :null => false
       t.integer :crp_sector_id, :null => true
     end
     
     create_table :crp_interest_groups do |t|      
       t.string :osid, :null => false
       t.string :name, :null => true
       t.integer :crp_industry_id, :null => true
       t.string :order, :null => true
     end
     add_index :crp_interest_groups, :osid
     
     create_table :crp_pacs do |t|      
       t.string :fec_id, :null => false
       t.string :osid, :null => false
       t.string :name, :null => false
       t.integer :affiliate_pac_id, :null => true
       t.integer :parent_pac_id, :null => true
       t.string :recipient_type, :null => true
       t.integer :recipient_person_id, :null => true
       t.string :party, :null => true
       t.integer :crp_interest_group_id, :null => true
       t.string :crp_interest_group_source, :null => true
       t.boolean :is_sensitive, :default => false
       t.boolean :is_foreign, :default => false
       t.boolean :is_active, :default => true
     end
       
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
     
     create_table :crp_contrib_pac_to_candidate, :id => false do |t|  
       t.string :cycle, :null => false
       t.string :fec_trans_id, :null => false    
       t.string :crp_pac_osid, :null => false    
       t.string :recipient_osid, :null => true    
       t.integer :amount, :null => false
       t.date :contrib_date, :null => false
       t.string :crp_interest_group_osid, :null => true
       t.string :contrib_type, :null => true
       t.string :direct_or_indirect, :null => false
     end
     add_index :crp_contrib_pac_to_candidate, :recipient_osid
     add_index :crp_contrib_pac_to_candidate, :crp_interest_group_osid
     
     create_table :crp_contrib_pac_to_pac, :id => false do |t|  
       t.string :cycle, :null => false
       t.string :fec_trans_id, :null => false    
       t.string :filer_osid, :null => true    
       t.string :donor_name, :null => true  
       t.string :filer_name, :null => true  
       t.string :donor_city, :null => true
       t.string :donor_state, :null => true
       t.string :donor_zip, :null => true
       t.string :fed_occ_emp, :null => true
       t.string :donor_crp_interest_group_osid, :null => true
       t.date :contrib_date, :null => false
       t.float :amount, :null => true
       t.string :recipient_osid, :null => true
       t.string :party, :null => true
       t.string :other_id, :null => true
       t.string :recipient_type, :null => true
       t.string :recipient_crp_interest_group_osid, :null => true
       t.string :amended, :null => true
       t.string :report_type, :null => true
       t.string :election_type, :null => true
       t.string :microfilm, :null => true
       t.string :contrib_type, :null => true
       t.string :donor_realcode_crp_interest_group_osid, :null => true
       t.string :realcode_source, :null => true
     end
     add_index :crp_contrib_pac_to_pac, :filer_osid
     add_index :crp_contrib_pac_to_pac, :recipient_crp_interest_group_osid
     
    create_table :bill_interest_groups do |t|  
      t.integer :bill_id, :null => false
      t.integer :crp_interest_group_id, :null => false
      t.string :disposition, :null => true
      t.text :citation, :null => true
    end
  end

  def self.down
    drop_table :crp_sectors
    drop_table :crp_industries    
    drop_table :crp_interest_groups
    drop_table :crp_pacs  
    drop_table :crp_contrib_individual_to_candidate
    drop_table :crp_contrib_pac_to_candidate
    drop_table :crp_contrib_pac_to_pac
    drop_table :bill_interest_groups
    
    create_table :people_sectors, :id => false do |t|
      t.column "person_id", :integer
      t.column "sector_id", :string
      t.column "total", :integer
      t.column "revision_date", :datetime
    end
    create_table :sectors do |t|
      t.column "name", :string
    end
    create_table :contributors do |t|
      t.column "name", :string
    end
  end
end
