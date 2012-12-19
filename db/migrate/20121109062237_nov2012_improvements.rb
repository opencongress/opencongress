class Nov2012Improvements < ActiveRecord::Migration
  def self.up
    execute "DROP INDEX bills_cosponsors_person_id_index"
    add_index :bills_cosponsors, :person_id
    add_index :bills_cosponsors, :bill_id
    
    execute "DROP INDEX bills_committees_bill_id_index"
    add_index :bills_committees, :committee_id
    add_index :bills_committees, :bill_id
    
    add_index :notebook_items, :political_notebook_id
    
    add_index :actions, :roll_call_id
    
    add_index :roll_calls, :bill_id
    add_index :roll_calls, :amendment_id
    add_index :bill_position_organizations, :bill_id
    add_index :contact_congress_letters_formageddon_threads, :contact_congress_letter_id, :name => "index_cclft_cclid"
    add_index :contact_congress_letters_formageddon_threads, :formageddon_thread_id, :name => "index_cclft_ftid"
    
    add_index :bills, :introduced
    
    add_column :contact_congress_letters, :is_public, :boolean, :default => false
    ContactCongressLetter.all.each do |ccl|
      ccl.is_public = (ccl.formageddon_threads.first.privacy == 'PUBLIC')
      ccl.save
    end
  end

  def self.down
    remove_index :bills_cosponsors, :person_id
    remove_index :bills_cosponsors, :bill_id
    execute "CREATE INDEX bills_cosponsors_person_id_index ON bills_cosponsors (person_id, bill_id)"
    
    remove_index :bills_committees, :committee_id
    remove_index :bills_committees, :bill_id
    execute "CREATE INDEX bills_committees_bill_id_index ON bills_committees (bill_id, committee_id)"
    
    remove_index :notebook_items, :political_notebook_id
    
    remove_index :actions, :roll_call_id
    
    remove_index :roll_calls, :bill_id
    remove_index :roll_calls, :amendment_id
    remove_index :bill_position_organizations, :bill_id
    remove_index :contact_congress_letters_formageddon_threads, :name => "index_cclft_cclid"
    remove_index :contact_congress_letters_formageddon_threads, :name => "index_cclft_ftid"
    
    remove_index :bills, :introduced
    
    remove_column :contact_congress_letters, :is_public
  end
end
