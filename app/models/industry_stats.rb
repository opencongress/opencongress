class IndustryStats < ActiveRecord::Base
  set_primary_key :sector_id
  
  belongs_to :sector
end