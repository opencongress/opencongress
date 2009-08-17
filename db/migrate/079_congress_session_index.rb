class CongressSessionIndex < ActiveRecord::Migration
  def self.up
    add_index :congress_sessions, :date
    add_index :roles, :person_id
  end
  
  def self.down
    remove_index :congress_sessions, :date
    remove_index :roles, :person_id
  end
end