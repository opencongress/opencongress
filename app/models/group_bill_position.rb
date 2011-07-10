class GroupBillPosition < ActiveRecord::Base
  belongs_to :group
  belongs_to :bill
  
  validates_presence_of :group_id
  validates_presence_of :bill_id
  validates_presence_of :position
end
