#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../../config/environment'
else
  puts "Running from #{$0}"
end

require 'json'
require 'open-uri'

people = Person.all_sitting

people.each_with_index do |p, i|
  puts "Checking fundraisers for #{p.name} (#{i+1}/#{people.size})"
  
  begin
    events = JSON.parse(open("http://politicalpartytime.org/json/#{p.osid}/").read)
  
    events.each do |e|
    
      puts "Got: #{e['fields']['entertainment']}"
    
      f = Fundraiser.find_or_create_by_sunlight_id(e['pk'])
      f.person = p
      f.host = e['fields']['hosts'].join(", ")
      f.beneficiaries = e['fields']['beneficiaries'].join(", ")
    
      begin
        f.start_time = DateTime.parse("#{e['fields']['start_date']} #{e['fields']['start_time']}")
      rescue
        f.start_time = nil
      end
    
      begin
        f.end_time = DateTime.parse("#{e['fields']['end_date']} #{e['fields']['end_time']}")
      rescue
        f.end_time = nil
      end
    
      f.venue = e['fields']['venue']
      f.entertainment_type = e['fields']['entertainment']
      f.venue_address1 = e['fields']['venue_address1']
      f.venue_address2 = e['fields']['venue_address2']
      f.venue_city = e['fields']['venue_city']
      f.venue_state = e['fields']['venue_state']
      f.venue_zipcode = e['fields']['venue_zipcode']
      f.venue_website = e['fields']['venue_website']
      f.contributions_info = e['fields']['contributions_info']
      f.latlong = e['fields']['latlong']
      f.rsvp_info = e['fields']['rsvp_info']
      f.distribution_payer = e['fields']['distribution_paid_for_by']
      f.make_checks_payable_to = e['fields']['make_checks_payable_to']
      f.checks_payable_address = e['fields']['checks_payable_to_address']
      f.committee_id = e['fields']['committee_id']

      f.save
    end
  rescue
    puts "Error getting fundraisers for #{p.name}"
  end
end
