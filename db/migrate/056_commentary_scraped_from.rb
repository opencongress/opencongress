class CommentaryScrapedFrom < ActiveRecord::Migration
  def self.up
    add_column :commentaries, :scraped_from, :string
    change_column :commentaries, :url, :text
    
    execute "UPDATE commentaries SET scraped_from='google news' WHERE commentary_type='news'"
    execute "UPDATE commentaries SET scraped_from='technorati' WHERE commentary_type='blog'"
  end

  def self.down
    remove_column :commentaries, :scraped_from
    change_column :commentaries, :url, :string
  end
end