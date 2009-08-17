class HotBillCategory < ActiveRecord::Base  
  has_many :bills
  has_many :notebook_items
end