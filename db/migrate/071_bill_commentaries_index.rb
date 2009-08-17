class BillCommentariesIndex < ActiveRecord::Migration
  def self.up
    add_index :bill_fulltext, :bill_id
    
    remove_index :commentaries, [:bill_id, :person_id, :status, :commentary_type, :date]
    
    add_index :commentaries, :bill_id
    add_index :commentaries, :person_id
    add_index :commentaries, :date
    
    execute "VACUUM FULL ANALYZE"
  end
  
  def self.down
    remove_index :bill_fulltext, :bill_id
    

    remove_index :commentaries, :bill_id
    remove_index :commentaries, :person_id
    remove_index :commentaries, :date

    add_index :commentaries, [ :bill_id, :person_id, :status, :commentary_type, :date ]
  end
end