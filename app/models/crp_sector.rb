class CrpSector < ActiveRecord::Base
  has_many :crp_industries, :order => 'name'
  
  has_many :pvs_category_mappings, :as => :pvs_category_mappable
  has_many :pvs_categories, :through => :pvs_category_mappings
end