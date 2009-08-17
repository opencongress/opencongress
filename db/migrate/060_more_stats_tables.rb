class MoreStatsTables < ActiveRecord::Migration
  def self.up
    create_table :issue_stats, :id => false, :force => true do |t|
      t.column "subject_id", :integer, :null => false
      t.column "entered_top_viewed", :datetime
    end

    create_table :committee_stats, :id => false, :force => true do |t|
      t.column "committee_id", :integer, :null => false
      t.column "entered_top_viewed", :datetime
    end

    create_table :industry_stats, :id => false, :force => true do |t|
      t.column "sector_id", :integer, :null => false
      t.column "entered_top_viewed", :datetime
    end
   end

  def self.down
    drop_table :issue_stats
    drop_table :committee_stats
    drop_table :industry_stats
  end
end