#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../config/environment'
end

require 'uri'
require 'scrapi'
require 'rexml/document'
require 'ostruct'
require 'hpricot'
require 'open-uri'
require 'iconv'



# Get all senate bills for the current congress.
bills = Bill.find_all_by_session_and_bill_type(Settings.default_congress, 's')
i=0
bills.each do |b|
  i += 1
  puts "Checking senate bill #{i}/#{bills.size}"

  b.commentaries.each do |c|    
    c.status = c.senate_bill_strict_validity
    c.save
  end
end

i = 0
unless (ARGV[0] == 'senate-only')
  commentaries = Commentary.find(:all, :conditions => "status='OK' AND contains_term IS NULL")
  commentaries.each do |c|
    i += 1
    puts "Article #{i}/#{commentaries.size}"
    if c.article_valid?
      puts "Article for #{c.url} is valid.  Matched '#{c.contains_term}'"
    else
      puts "Article for #{c.url} is not valid."
      c.status = 'NO MATCH'
    end
  
    c.save
  end
end