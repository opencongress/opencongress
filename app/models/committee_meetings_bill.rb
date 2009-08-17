class CommitteeMeetingsBill < ActiveRecord::Base
  belongs_to :committee_meeting
  belongs_to :bill
end
