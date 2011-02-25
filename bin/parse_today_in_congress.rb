#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../config/environment'
end

require 'uri'
require 'rexml/document'
require 'ostruct'
require 'hpricot'
require 'open-uri'

doc = Hpricot(open("http://www.house.gov/house/floor/thisweek.htm"))
h_sessions = doc.search("center b")
if h_sessions
  h_sessions.each do |s|
    begin
      day_of_week, date_string = /(\w+) - (.*)$/.match(s.inner_html).captures

      date = Date.strptime(date_string, "%B %d, %Y")
    
      unless (CongressSession.find_by_date_and_chamber(date, 'house'))
        CongressSession.create({ :date => date, :chamber => 'house', :is_in_session => true})
        puts "Session for house:#{date} added to DB."
      else
        puts "Session for house:#{date} already in DB. Skipping."
      end
    rescue
      puts "Error parsing/adding date from the House!"
    end
  end
end

doc = Hpricot(open("http://www.senate.gov/"))
s_session = (doc.at("#floorSchedule p b").inner_html)

if s_session && (s_session = /(.*) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) (\d+), (\d+)/.match(s_session))
  junk, month, day_of_month, year = s_session.captures
  
  date = Date.strptime("#{month} #{day_of_month} #{year}", "%b %d %Y")

  unless (CongressSession.find_by_date_and_chamber(date, 'senate'))
    CongressSession.create({ :date => date, :chamber => 'senate', :is_in_session => true})
    puts "Session for senate:#{date} added to DB."
  else
    puts "Session for senate:#{date} already in DB. Skipping."
  end
end

# check the govtrack data just to see if we've missed a date:

##
## Jan 28, 2011 GovTrack no longer putting these files in data
##

# File.open("#{GOVTRACK_DATA_PATH}/congress.nextsession.house", "r") do |f|
#   f.each_line do |line| 
#     date = Time.at(line.to_i)
# 
#     unless (CongressSession.find_by_date_and_chamber(date, 'house'))
#       CongressSession.create({ :date => date, :chamber => 'house', :is_in_session => true})
#       puts "Session for house:#{date} added to DB."
#     else
#       puts "Session for house:#{date} already in DB. Skipping."
#     end
#   end
# end
# 
# File.open("#{GOVTRACK_DATA_PATH}/congress.nextsession.senate", "r") do |f|
#   f.each_line do |line| 
#     date = Time.at(line.to_i)
# 
#     unless (CongressSession.find_by_date_and_chamber(date, 'senate'))
#       CongressSession.create({ :date => date, :chamber => 'senate', :is_in_session => true})
#       puts "Session for senate:#{date} added to DB."
#     else
#       puts "Session for senate:#{date} already in DB. Skipping."
#     end
#   end
# end