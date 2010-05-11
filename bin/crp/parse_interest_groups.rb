#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../../config/environment'
else
  puts "Running from #{$0}"
end

file = "#{OPENSECRETS_DATA_PATH}/CRP_Categories.txt"
IO.foreach(file) do |line|
  line.chomp!
  
  if line =~ /^[A-Z][A-Z|0-9][0-9][0-9][0-9]/
    puts "Read a line."
    
    id, name, order, industry, sector, sector_long = line.split("\t")
    #vals = line.split("\t")
    
    #puts vals.inspect
    
    name.gsub!(/\"/, '')
    industry.gsub!(/\"/, '')
    sector.gsub!(/\"/, '')
    sector_long.gsub!(/\"/, '')
    
    s = CrpSector.find_or_initialize_by_name(sector)
    s.display_name = sector_long
    s.save
    
    i = CrpIndustry.find_or_initialize_by_name(industry)
    i.crp_sector = s
    i.save
    
    g = CrpInterestGroup.find_or_initialize_by_osid(id)
    g.name = name
    g.order = order
    g.crp_industry = i
    g.save
  else
    puts "Skipping line."
  end
end
