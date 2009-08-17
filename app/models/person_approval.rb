#
# Model for end-user approval ratings of congresspeople
#
class PersonApproval < ActiveRecord::Base

  belongs_to :person
  belongs_to :user

end
