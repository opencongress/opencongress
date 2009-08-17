class AddBillVoteIndexes < ActiveRecord::Migration
  def self.up
    add_index :bill_votes, :created_at
    add_index :bill_votes, :bill_id
  end

  def self.down
    remove_index :bill_votes, :created_at
    remove_index :bill_votes, :bill_id
  end
end
