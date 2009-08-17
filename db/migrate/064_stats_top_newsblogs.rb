class StatsTopNewsblogs < ActiveRecord::Migration
  def self.up
    add_column :person_stats, :entered_top_news, :datetime
    add_column :person_stats, :entered_top_blog, :datetime
    add_column :bill_stats, :entered_top_news, :datetime
    add_column :bill_stats, :entered_top_blog, :datetime
  end
  
  def self.down
    remove_column :person_stats, :entered_top_news
    remove_column :person_stats, :entered_top_blog
    remove_column :bill_stats, :entered_top_news
    remove_column :bill_stats, :entered_top_blog
  end 
end