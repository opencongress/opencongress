#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../../config/environment'
else
  puts "Running from #{$0}"
end

def do_stats_for_person(s)
  s.person_stats.sponsored_bills = s.bills.count
  s.person_stats.cosponsored_bills = s.bills_cosponsored.count
  s.person_stats.sponsored_bills_passed = s.bills.select{ |b| b.enacted_action != nil }.size
  s.person_stats.cosponsored_bills_passed = s.bills_cosponsored.select{ |b| b.enacted_action != nil }.size
  s.person_stats.abstains_percentage = s.abstains_percentage
  s.person_stats.abstains = s.abstained_roll_calls.count
  case s.party
  when 'Democrat'
      s.person_stats.party_votes_percentage = s.with_party_percentage
  when 'Republican'
      s.person_stats.party_votes_percentage = s.with_party_percentage
  else
      s.person_stats.party_votes_percentage = 0.0
  end

  s.person_stats.party_votes_percentage = 0.0 if s.person_stats.party_votes_percentage.nil?

  s.person_stats.save

  
  # force garbage collection
  s = nil
end

puts "Calculating sponsored bills stats..."
peoples = [ Person.senators, Person.representatives ]
peoples.each do |people|
  
  i = 1
  total = people.size
  while(s = people.pop)
    puts "Calculating sponsored bills stats for #{s.name} (#{i}/#{total})"
  
    do_stats_for_person(s)
    
    i += 1
  end
end

people_types = [ 'sen', 'rep' ]
people_types.each do |p_type|
  joined_people = Person.find(:all,
                        :include => [:roles, :person_stats],
                        :conditions => [ "roles.role_type=? AND roles.startdate <= ? AND roles.enddate >= ? ",
                               p_type, OpenCongress::Application::CONGRESS_START_DATES[Settings.default_congress], OpenCongress::Application::CONGRESS_START_DATES[Settings.default_congress] ])

  puts joined_people.inspect
  
  joined_people.sort! { |a,b| b.person_stats.sponsored_bills <=> a.person_stats.sponsored_bills }
  i = 1
  previous_count = -1
  current_rank = -1
  joined_people.each do |person|
    if previous_count != person.person_stats.sponsored_bills
      current_rank = i
      previous_count = person.person_stats.sponsored_bills
    end
    
    puts "#{person.name}: SC: #{person.person_stats.sponsored_bills}; Rank: #{current_rank}"
    
    person.person_stats.sponsored_bills_rank = current_rank
    person.person_stats.save
  
    i += 1
  end

  joined_people.sort! { |a,b| b.person_stats.cosponsored_bills <=> a.person_stats.cosponsored_bills }
  i = 1
  previous_count = -1
  current_rank = -1
  joined_people.each do |person|
    if previous_count != person.person_stats.cosponsored_bills
      current_rank = i
      previous_count = person.person_stats.cosponsored_bills
    end
    
    puts "#{person.name}: SC: #{person.person_stats.cosponsored_bills}; Rank: #{current_rank}"
    
    person.person_stats.cosponsored_bills_rank = current_rank
    person.person_stats.save
  
    i += 1
  end

  joined_people_2 = joined_people.select {|g| !g.person_stats.party_votes_percentage.nil? }.flatten.sort { |a,b| b.person_stats.party_votes_percentage <=> a.person_stats.party_votes_percentage }
  i = 1
  previous_count = -1.0
  current_rank = -1
  joined_people_2.each do |person|
    if previous_count != person.person_stats.party_votes_percentage
      current_rank = i
      previous_count = person.person_stats.party_votes_percentage
    end
    
    puts "#{person.name}: SC: #{person.person_stats.party_votes_percentage}; Rank: #{current_rank}"
    
    person.person_stats.party_votes_percentage_rank = current_rank
    person.person_stats.save
  
    i += 1
  end

  joined_people_2 = joined_people.select {|g| !g.person_stats.abstains_percentage.nil? }.sort { |a,b| b.person_stats.abstains_percentage <=> a.person_stats.abstains_percentage }
  i = 1
  previous_count = -1.0
  current_rank = -1
  joined_people_2.each do |person|
    if previous_count != person.person_stats.abstains_percentage
      current_rank = i
      previous_count = person.person_stats.abstains_percentage
    end
    
    puts "#{person.name}: SC: #{person.person_stats.abstains_percentage}; Rank: #{current_rank}"
    
    person.person_stats.abstains_percentage_rank = current_rank
    person.person_stats.save
  
    i += 1
  end

  joined_people.sort! { |a,b| b.person_stats.sponsored_bills_passed <=> a.person_stats.sponsored_bills_passed }
  i = 1
  previous_count = -1
  current_rank = -1
  joined_people.each do |person|
    if previous_count != person.person_stats.sponsored_bills_passed
      current_rank = i
      previous_count = person.person_stats.sponsored_bills_passed
    end
    
    puts "#{person.name}: SC: #{person.person_stats.sponsored_bills_passed}; Rank: #{current_rank}"
    
    person.person_stats.sponsored_bills_passed_rank = current_rank
    person.person_stats.save
  
    i += 1
  end

  joined_people.sort! { |a,b| b.person_stats.cosponsored_bills_passed <=> a.person_stats.cosponsored_bills_passed }
  i = 1
  previous_count = -1
  current_rank = -1
  joined_people.each do |person|
    if previous_count != person.person_stats.cosponsored_bills_passed
      current_rank = i
      previous_count = person.person_stats.cosponsored_bills_passed
    end
    
    puts "#{person.name}: SC: #{person.person_stats.cosponsored_bills_passed}; Rank: #{current_rank}"
    
    person.person_stats.cosponsored_bills_passed_rank = current_rank
    person.person_stats.save
  
    i += 1
  end
end
