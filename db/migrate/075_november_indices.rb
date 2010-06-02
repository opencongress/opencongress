class NovemberIndices < ActiveRecord::Migration
  def self.up
    #done manually
    remove_index :commentaries, :date

    add_index :commentaries, [:date, :commentary_type]
    
    # the first index is an unnecessary multi column index
    remove_index :bill_subjects, [:bill_id, :subject_id]
    
    add_index :bill_subjects, :bill_id

    #execute "VACUUM ANALYZE commentaries" 
    #execute "VACUUM ANALYZE bill_subjects" 
  end

  
  def self.down

  end
end