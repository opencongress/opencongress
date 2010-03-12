class CongressSession < ActiveRecord::Base
  def CongressSession.house_session
    find(:first, :conditions => ["date >=? AND chamber='house' AND is_in_session='t'", Date.today])
  end

  def CongressSession.senate_session
    find(:first, :conditions => ["date >=? AND chamber='senate' AND is_in_session='t'", Date.today])
  end
  
  def CongressSession.recess_session
    find(:first, :conditions => "chamber='recess'")
  end
  
  def self.sessions
    { :house_session => CongressSession.house_session, :senate_session => CongressSession.senate_session, :recess_session => CongressSession.recess_session }
  end
  
  def today?
    date == Date.today
  end
end
