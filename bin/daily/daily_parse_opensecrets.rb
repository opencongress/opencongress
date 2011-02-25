#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../../config/environment'
else
  puts "Running from #{$0}"
end

require 'rexml/document'
require 'ostruct'
require 'date'
require 'yaml'

USERAGENT = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.1) Gecko/20060111 Firefox/1.5.0.1'

sectors = {}
contribs = {}

Person.all_sitting.each do |p|
  if p.osid
    puts "Getting OpenSecrets data for #{p.name}"
    
    path = "/api/index.php?method=opencongress&cycle=#{Settings.current_opensecrets_cycle}&cid=#{p.osid}&apikey=#{API_KEYS['opensecrets_api_key']}"
    
    success = false
    badcount = 0
    until success
      begin
        response = nil;
        http = Net::HTTP.new('www.opensecrets.org')
        http.start do |http|
          request = Net::HTTP::Get.new(path, {"User-Agent" => USERAGENT})
          response = http.request(request)
        end
        success = true
      rescue
        puts "Error getting data for #{p.name}: #{$!}"
        badcount += 1
        if badcount > 5
          puts "Five consecutive errors.  Something must be wrong.  Exiting."
          raise "Five consecutive HTTP errors!"
        end
      end
    end
    
    doc = REXML::Document.new response.body
    es = doc.elements
    
    es.each("crp_results/data[@type='sectors']") do |e|
      #puts "#{e.elements['sector'].text} : #{e.elements['total'].text}"
      
      sector = e.elements['sector'].text
      total = e.elements['total'].text
      
      s = Sector.find_or_create_by_name(sector)
      sectors[sector] ||= s
      ps = PersonSector.find_or_initialize_by_person_id_and_sector_id_and_cycle(p.id, s.id, Settings.current_opensecrets_cycle)
      ps.total = total
      ps.save
    end
    
    es.each("crp_results/data[@type='top_contrib']") do |e|
      #puts "#{e.elements['contributor'].text} : #{e.elements['total'].text}"
      contributor = e.elements['contributor'].text
      amount = e.elements['total'].text
      
      c = contribs[contributor] || Contributor.find_or_create_by_name(e.elements['contributor'].text)
      contribs[contributor] ||= c
      
      pcc = PersonCycleContribution.find_or_initialize_by_person_id_and_cycle(p.id, Settings.current_opensecrets_cycle)
      pcc.top_contributor = c
      pcc.top_contributor_amount = amount
      pcc.save
    end
    
    es.each("crp_results/data[@type='total_raised']") do |e|
      #puts "Total: #{e.elements['total'].text}"
      
      total_raised = e.elements['total'].text
      pcc = PersonCycleContribution.find_or_initialize_by_person_id_and_cycle(p.id, Settings.current_opensecrets_cycle)
      pcc.total_raised = total_raised
      pcc.save
    end
  end
end
