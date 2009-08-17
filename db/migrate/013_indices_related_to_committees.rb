class IndicesRelatedToCommittees < ActiveRecord::Migration
  def self.up
    add_index :bills_committees, [:bill_id, :committee_id]
    add_index :actions, :bill_id
    add_index :bill_titles, :bill_id
  end
  
  def self.down
    remove_index :bills_committees, [:bill_id, :committee_id]
    remove_index :actions, :bill_id
    remove_index :bill_titles, :bill_id
  end
end
