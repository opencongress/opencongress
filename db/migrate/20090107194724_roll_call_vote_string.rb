class RollCallVoteString < ActiveRecord::Migration
  def self.up
    change_column :roll_call_votes, :vote, :string
  end

  def self.down
  end
end
