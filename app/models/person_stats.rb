class PersonStats < ActiveRecord::Base
  set_primary_key :person_id
  
  belongs_to :person
  
  belongs_to :votes_most_often_with, :class_name => 'Person', :foreign_key => 'votes_most_often_with_id'
  belongs_to :votes_least_often_with, :class_name => 'Person', :foreign_key => 'votes_least_often_with_id'
  belongs_to :opposing_party_votes_most_often_with, :class_name => 'Person', :foreign_key => 'opposing_party_votes_most_often_with_id'
  belongs_to :same_party_votes_least_often_with, :class_name => 'Person', :foreign_key => 'same_party_votes_least_often_with_id'
  
  
  def full_name
    "#{firstname} #{lastname}"
  end
  def title_full_name
		"#{title} " + full_name
	end
	
end
