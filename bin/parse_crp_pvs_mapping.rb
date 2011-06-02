#!/usr/bin/env ruby

#### LOAD RAILS ENVIRONMENT
APP_PATH = File.expand_path('../../config/application',  __FILE__)
require File.expand_path('../../config/boot',  __FILE__)
ENV["RAILS_ENV"] ||= "development"
require APP_PATH
Rails.application.require_environment!
###########################

file = File.new(File.dirname(__FILE__) + '/../db/PVS-CRP.csv', "r")
puts "opening file: #{file}"
while (line = file.gets)
puts "GOT LINE: #{line}"
  pvs_name, crp_industry_name, crp_sector_name = line.split(/,(?!(?:[^",]|[^"],[^"])+")/)
  
  pvs_name.gsub!(/"/, '') unless pvs_name.nil?
  crp_industry_name.gsub!(/"/, '') unless crp_industry_name.nil?
  crp_sector_name.gsub!(/"/, '') unless crp_sector_name.nil?
  crp_sector_name.chomp! unless crp_sector_name.nil?
  
  puts "splits: #{pvs_name}|#{crp_industry_name}|#{crp_sector_name}"
 
  pvs_category = PvsCategory.find_by_name(pvs_name)
  puts "PVS: #{pvs_category}"
  
  crp_i_names = crp_industry_name.split(/,/)
  crp_i_names.each do |i_name|
    i_name.strip!
    crp_industry = CrpIndustry.find_by_name(i_name)
    pvs_category.crp_industries << crp_industry unless crp_industry.nil?
    puts "CRPI: #{crp_industry}"
  end
  crp_sector = CrpSector.find_by_display_name(crp_sector_name)
  pvs_category.crp_sectors << crp_sector unless crp_sector.nil?
  puts "CRPS: #{crp_sector}"
end

file.close