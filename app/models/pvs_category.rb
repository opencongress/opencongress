class PvsCategory < ActiveRecord::Base  
  has_many :hot_bills, :class_name => "Bill", :foreign_key => :hot_bill_category_id
  has_many :key_vote_bills, :class_name => "Bill", :foreign_key => :key_vote_category_id
  has_many :key_vote_amendments, :class_name => "Amendment", :foreign_key => :hot_bill_category_id
end