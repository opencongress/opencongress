class PersonBillStats < ActiveRecord::Migration
  def self.up
    add_column :person_stats, :sponsored_bills, :integer
    add_column :person_stats, :cosponsored_bills, :integer
    add_column :person_stats, :sponsored_bills_passed, :integer
    add_column :person_stats, :cosponsored_bills_passed, :integer
    add_column :person_stats, :sponsored_bills_rank, :integer
    add_column :person_stats, :cosponsored_bills_rank, :integer
    add_column :person_stats, :sponsored_bills_passed_rank, :integer
    add_column :person_stats, :cosponsored_bills_passed_rank, :integer
  end
  
  def self.down
    remove_column :person_stats, :sponsored_bills
    remove_column :person_stats, :cosponsored_bills
    remove_column :person_stats, :sponsored_bills_passed
    remove_column :person_stats, :cosponsored_bills_passed
    remove_column :person_stats, :sponsored_bills_rank
    remove_column :person_stats, :cosponsored_bills_rank
    remove_column :person_stats, :sponsored_bills_passed_rank
    remove_column :person_stats, :cosponsored_bills_passed_rank
  end
end
