class AddBillVotesUserIdIndex < ActiveRecord::Migration
  def self.up
   add_index :bill_votes, :user_id
  end

  def self.down
   remove_index :bill_votes, :user_id
  end
end
