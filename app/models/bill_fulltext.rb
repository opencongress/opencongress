class BillFulltext < ActiveRecord::Base
  set_primary_key :bill_id
  set_table_name :bill_fulltext
  
  belongs_to :bill
end
