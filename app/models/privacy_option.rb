class PrivacyOption < ActiveRecord::Base
  belongs_to :user
  after_save :save_associated_user
  
  private
  def save_associated_user
    self.user.solr_save
  end
end
