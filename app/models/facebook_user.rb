class FacebookUser < ActiveRecord::Base  
  has_many :facebook_user_bills
  
  #def FacebookUser.find_or_create_by_facebook_session(fbs)
  #  FacebookUser.find_or_create_by_facebook_session_key_and_facebook_uid(fbs.session_key, fbs.session_user_id)
  #end
  
  #def FacebookUser.update_profiles
  #  app = ActionController::Integration::Session.new
  
  #  app.get("/facebook/update_profiles")
  #end
end