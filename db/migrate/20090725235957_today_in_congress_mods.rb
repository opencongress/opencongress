class TodayInCongressMods < ActiveRecord::Migration
  def self.up
    add_column :congress_sessions, :is_in_session, :boolean
    
    execute "UPDATE congress_sessions SET is_in_session='t'"
    
    CongressSession.create(:chamber => 'recess', :is_in_session => true, :date => Date.new(y=2009,m=7,d=31))  
  end

  def self.down
    remove_column :congress_sessions, :is_in_session
    
    sesh = CongressSession.find(:first, :conditions => "chamber='recess'")
    sesh.destroy 
  end
end
