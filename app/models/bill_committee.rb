class BillCommittee < ActiveRecord::Base
  set_table_name 'bills_committees'
  validates_uniqueness_of :bill_id, :scope => :committee_id

  belongs_to :bill
  belongs_to :committee  
end
