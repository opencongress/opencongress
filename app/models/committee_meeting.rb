class CommitteeMeeting < ActiveRecord::Base
  validates_uniqueness_of :meeting_at, :scope => :committee_id

  belongs_to :committee

  has_many :committee_meetings_bills 
  has_many :bills, :through => :committee_meetings_bills
end
