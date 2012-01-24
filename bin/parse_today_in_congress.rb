#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../config/environment'
end

require 'uri'
require 'rexml/document'
require 'ostruct'
require 'hpricot'
require 'open-uri'

begin
  doc = Hpricot(open("http://www.house.gov/legislative/date/#{Time.now.year}-#{'%02d' % Time.now.month}-#{'%02d' % Time.now.day}"))
  date = Date.today

  unless (CongressSession.find_by_date_and_chamber(date, 'house'))
    not_in_session = (doc.to_s =~ /There are no events scheduled today/)
    
    CongressSession.create({ :date => date, :chamber => 'house', :is_in_session => !not_in_session})
    puts "Session for house:#{date} added to DB."
  else
    puts "Session for house:#{date} already in DB. Skipping."
  end
rescue
  puts "Error parsing/adding date from the House!"
end

begin
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
rescue
  puts "Error parsing/adding date from the Senate!"
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