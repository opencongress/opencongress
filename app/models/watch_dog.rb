class WatchDog < ActiveRecord::Base

  belongs_to :district
  belongs_to :user
  
  def self.recent_actions
    

  end
  
  def login_district
    self.user.login + " (#{district.district_state_text})"
  end

end
