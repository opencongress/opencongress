class BillStats < ActiveRecord::Base
  set_primary_key :bill_id
  
  belongs_to :bill
end