class ParsingIndices < ActiveRecord::Migration
  def self.up
    add_index :bills, [:number, :session, :bill_type]
    add_index :committee_reports, :name
    add_index :people, [:firstname, :lastname]
    add_index :bills_cosponsors, [:person_id, :bill_id]
    add_index :bills_relations, [:bill_id, :related_bill_id]
    add_index :amendments, [:bill_id, :number]

 #  add_index :actions, :bill_id    
 #  add_index :bill_subjects, [:bill_id, :subject_id] ## added in 016
 #  add_index :bills_committees, [:bill_id, :committee_id] ## added in 013
  end

  def self.down
    remove_index :bills, :number
    remove_index :committee_reports, :name
    remove_index :people, :firstname
    remove_index :bills_cosponsors, :person_id
    remove_index :bills_relations, :bill_id
    remove_index :amendments, :bill_id
    
 #  remove_index :actions, :bill_id 
 #  remove_index :bill_subjects, :bill_id ## added in 016
 #  remove_index :bills_committees, :bill_id ## added in 013
  end
end
