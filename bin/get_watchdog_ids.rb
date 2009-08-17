#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../config/environment'
else
  puts "Running from #{$0}"
end

require 'rubygems'
require 'hpricot'
require 'open-uri'

states = State.find(:all)
states.each do |state|
  puts "Looking for #{state.name}"

  url = "http://watchdog.net/us/#{state.abbreviation.downcase}"
  doc = Hpricot(open(url))

  links = (doc/"a")
  links.each do |l|
    if l.inner_html =~ /Sen\.\s/
      sen = Person.find(:first, :conditions => ["LOWER(lastname) = ? AND title = 'Sen.'", l.inner_html.split.last.downcase])
      if sen
        puts "#{sen.name}: #{l['href'].split(/\//).last}"
        sen.watchdog_id = l['href'].split(/\//).last
        sen.save
      end
    end
  end
end


Person.representatives.each do |r|
  url = sprintf("http://watchdog.net/us/%s-%02d", r.state, r.district)
  #puts "going: #{url}"
  doc = Hpricot(open(url))
  
  links = (doc/"a")
  found_id = false
  links.each do |l|
    if l['href'] =~ /#{r.lastname.downcase}/
      puts "#{r.name}: #{l['href'].split(/\//).last}"
      r.watchdog_id = l['href'].split(/\//).last
      found_id = true
      break
    end
  end
    
  unless found_id
    puts "#{r.name}: didn't find. using #{r.firstname.downcase.gsub(/\s/, "_")}_#{r.lastname.downcase.gsub(/\s/, "_")}" 
    r.watchdog_id = "#{r.firstname.downcase.gsub(/\s/, "_")}_#{r.lastname.downcase.gsub(/\s/, "_")}"
  end

  r.save
end
  