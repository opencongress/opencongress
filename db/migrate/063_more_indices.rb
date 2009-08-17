class MoreIndices < ActiveRecord::Migration
  def self.up
    add_index :roll_call_votes, :person_id
    add_index :page_views, :ip_address
    add_index :commentaries, :url
    
    add_column :commentaries, :created_at, :timestamp
  end
  
  def self.down
    remove_index :page_views, :ip_address
    remove_index :roll_call_votes, :person_id
    remove_index :commentaries, :url

    remove_column :commentaries, :created_at
  end 
end