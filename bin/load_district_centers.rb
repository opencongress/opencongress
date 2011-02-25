#!/usr/bin/env ruby

# Preconditions:
# You will have run fetch_district_centers.sh
# Districts and states tables exist and are already populated--
# we are just updating their centers.

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../config/environment'
end

# You probably don't have this file in this spot.
FILE_NAME = File.join(Settings.govtrack_data_path, "110/geo/centers.json")

puts "Updating district centerpoints..."
i = IO.read(FILE_NAME)
states = i.scan(/\/us\/(\w\w)(\/cd\/110\/(\d+))?', (-?\d+.\d+), (-?\d+.\d+)/)
states.each do |state|
  # each state will be:
  # [state, ignore, district, long, lat] eg ["wv", ignore, "3", "-80.593244", "37.8572533333333"]
  # nil districts represent at-large districts
  if state[2].nil?
    state[2] = 0
  end
  if d = District.find(:first, :include => [:state], :conditions => ['states.abbreviation = ? and district_number = ?', state[0].upcase, state[2].to_i])
    d.update_attributes(:center_lat => state[4].to_f, :center_lng => state[3].to_f)
  end
end
