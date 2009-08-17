class PersonSector < ActiveRecord::Base
  set_table_name :people_sectors

  belongs_to :person
  belongs_to :sector
end
