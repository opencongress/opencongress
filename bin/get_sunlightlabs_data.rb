#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../config/environment'
else
  puts "Running from #{$0}"
end

require 'rubygems'
require 'hpricot'
require 'open-uri'


Person.all_sitting.each do |p|
  url = "http://services.sunlightlabs.com/api/legislators.get.xml?apikey=#{ApiKeys.sunlightlabs_key}&govtrack_id=#{p.id}"
  puts "Getting Sublight Labs data for: #{p.name}"
  
  doc = REXML::Document.new open(url)
  
  #puts "body: #{doc.to_s}"
  
  p.website = doc.elements['response/legislator/website'].text if doc.elements['response/legislator/website']
  p.congress_office = doc.elements['response/legislator/congress_office'].text if doc.elements['response/legislator/congress_office']
  p.phone = doc.elements['response/legislator/phone'].text if doc.elements['response/legislator/phone']
  p.fax = doc.elements['response/legislator/fax'].text if doc.elements['response/legislator/fax']
  p.contact_webform = doc.elements['response/legislator/webform'].text if doc.elements['response/legislator/webform']
  p.sunlight_nickname = doc.elements['response/legislator/nickname'].text if doc.elements['response/legislator/nickname']

  p.save  
end
