class PvsCategory < ActiveRecord::Base  
  has_many :hot_bills, :class_name => "Bill", :foreign_key => :hot_bill_category_id
  has_many :key_vote_bills, :class_name => "Bill", :foreign_key => :key_vote_category_id
  has_many :key_vote_amendments, :class_name => "Amendment", :foreign_key => :hot_bill_category_id
  
  has_many :pvs_category_mappings
  
  has_many :subjects, :through => :pvs_category_mappings, :source => :pvs_category_mappable, :source_type => 'Subject'
  has_many :crp_industries, :through => :pvs_category_mappings, :source => :pvs_category_mappable, :source_type => 'CrpIndustry'
  has_many :crp_sectors, :through => :pvs_category_mappings, :source => :pvs_category_mappable, :source_type => 'CrpSector'
end