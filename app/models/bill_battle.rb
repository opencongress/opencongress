class BillBattle < ActiveRecord::Base

  belongs_to :first_bill, :class_name => "Bill", :foreign_key => "first_bill_id"
  belongs_to :second_bill, :class_name => "Bill", :foreign_key => "second_bill_id"
  has_many :comments, :as => :commentable

end
