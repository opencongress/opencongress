class CommitteeStats < ActiveRecord::Base
  set_primary_key :committee_id
  
  belongs_to :committee
end