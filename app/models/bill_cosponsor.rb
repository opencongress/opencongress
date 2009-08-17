class BillCosponsor < ActiveRecord::Base
  set_table_name :bills_cosponsors

  belongs_to :person  
  belongs_to :bill
end
