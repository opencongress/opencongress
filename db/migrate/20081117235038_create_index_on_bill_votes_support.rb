class CreateIndexOnBillVotesSupport < ActiveRecord::Migration
  def self.up
#   add_index :bill_votes, :support
   add_index :comments, [:created_at, :commentable_type]
  end

  def self.down
   remove_index :bill_votes, :support
   remove_index :comments, [:created_at, :commentable_type]
  end
end
