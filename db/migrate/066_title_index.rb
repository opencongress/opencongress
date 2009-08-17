class TitleIndex < ActiveRecord::Migration
  def self.up
    add_index :bill_titles, :title
  end
  
  def self.down
    remove_index :bill_titles, :title
  end
end