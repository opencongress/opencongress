object false

child (@people => :people) {
  extends "person/base"
  attributes :with_party_percentage, :votes_democratic_position, :votes_republican_position, :recent_news, :recent_blogs, :person_stats
}

code(:total_pages) { @people.total_pages }
