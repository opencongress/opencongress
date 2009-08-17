class ArticlesExcerpt < ActiveRecord::Migration
  def self.up
    add_column :articles, :excerpt, :text
  end
  
  def self.down
    remove_column :articles, :excerpt
  end 
end