class AddVotesWithPartyPercentageAndRank < ActiveRecord::Migration
  def self.up
    add_column :person_stats, :party_votes_percentage, :float
    add_column :person_stats, :party_votes_percentage_rank, :integer
    add_column :person_stats, :abstains_percentage, :float
    add_column :person_stats, :abstains, :integer
    add_column :person_stats, :abstains_percentage_rank, :integer
  end

  def self.down
    remove_column :person_stats, :party_votes_percentage
    remove_column :person_stats, :party_votes_percentage_rank
    remove_column :person_stats, :abstains_percentage
    remove_column :person_stats, :abstains
    remove_column :person_stats, :abstains_percentage_rank
  end
end
