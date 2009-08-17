class CommitteePerson < ActiveRecord::Base
  validates_uniqueness_of :person_id, :scope => :committee_id
  validates_associated :person, :committee

  set_table_name :committees_people

  belongs_to :committee
  belongs_to :person
end
