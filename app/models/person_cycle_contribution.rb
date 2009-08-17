class PersonCycleContribution < ActiveRecord::Base
  set_table_name :people_cycle_contributions
  
  belongs_to :person
  belongs_to :top_contributor, :class_name => 'Contributor', :foreign_key => 'top_contributor_id' #Ha!
end