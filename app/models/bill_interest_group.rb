class BillInterestGroup < ActiveRecord::Base  
  belongs_to :bill
  belongs_to :crp_interest_group
end