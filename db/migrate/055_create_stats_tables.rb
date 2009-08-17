class CreateStatsTables < ActiveRecord::Migration
  def self.up
    create_table :bill_stats, :id => false, :force => true do |t|
      t.column "bill_id", :integer, :null => false
      t.column "entered_top_viewed", :datetime
    end

    create_table :person_stats, :id => false, :force => true do |t|
      t.column "person_id", :integer, :null => false
      t.column "entered_top_viewed", :datetime
      t.column "votes_most_often_with_id", :integer
      t.column "votes_least_often_with_id", :integer
      t.column "opposing_party_votes_most_often_with_id", :integer
      t.column "same_party_votes_least_often_with_id", :integer
    end
   end

  def self.down
    drop_table :bill_stats
    drop_table :person_stats
  end
end