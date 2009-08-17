class IssueStats < ActiveRecord::Base
  set_primary_key :subject_id
  
  belongs_to :subject
end