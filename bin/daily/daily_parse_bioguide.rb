#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../../config/environment'
else
  puts "Running from #{$0}"
end

require 'rubygems'
require 'hpricot'
require 'open-uri'

Person.all_sitting.each do |p|
  if p.bioguideid
    puts "Getting Biography data for #{p.name}"
    
    path = "/scripts/biodisplay.pl?index=#{p.bioguideid}"

    doc = Hpricot(open("http://bioguide.congress.gov#{path}"))
    if doc
      bio = (doc/'//table:eq(1)/tr/td:eq(1)/p:eq(0)')
      if bio
        name = (bio/'//font').inner_html
        formatted_bio = name + bio.inner_html.split(/<\/FONT>/i).last
        p.update_attribute(:biography, formatted_bio) if formatted_bio
#        puts formatted_bio
      else
        puts "NOOOOOOOOOOO BIO #{p.name}"
      end
    end
  end
end
