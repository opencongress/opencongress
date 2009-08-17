class CrpSector < ActiveRecord::Base
  has_many :crp_industries, :order => 'name'
end