class BillVote < ActiveRecord::Base
  # 1 = opposed, 0 = supported
  belongs_to :user
  belongs_to :bill
  after_save :save_associated_user
  
  
  private
  def save_associated_user
    self.user.solr_save
  end
end
