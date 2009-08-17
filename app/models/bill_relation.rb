class BillRelation < ActiveRecord::Base
  set_table_name :bills_relations

  belongs_to :related_bill, :class_name => 'Bill',
    :foreign_key => :related_bill_id
  belongs_to :bill
end
