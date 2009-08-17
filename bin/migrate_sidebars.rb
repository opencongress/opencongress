#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../../config/environment'
else
  puts "Running from #{$0}"
end

# make a holder class for site text from the dev database
class DevSidebar < ActiveRecord::Base
  set_table_name  "sidebars"

  has_many :sidebar_items, :class_name => 'DevSidebarItem', :foreign_key => 'sidebar_id'
  
  establish_connection "development"
end

class DevSidebarItem < ActiveRecord::Base
  set_table_name  "sidebar_items"

  establish_connection "development"
end


dev_sidebars = DevSidebar.find_all

dev_sidebars.each do |ds|
  s = Sidebar.find_by_page(ds.page)
  
  # right now only adding sidebars that aren't in DB
  unless s
    s = Sidebar.new
    s.page = ds.page
    s.class_type = ds.class_type
    s.title = ds.title
    s.description = ds.description
    s.enabled = ds.enabled

    # now add the items
    ds.sidebar_items.each do |dsi|
      si = SidebarItem.new
      si.bill_id = dsi.bill_id
      si.person_id = dsi.person_id
      si.committee_id = dsi.committee_id
      si.subject_id = dsi.subject_id
      si.description = dsi.description
      si.rank = dsi.rank
      s.sidebar_items << si
      si.save
    end
    
    s.save
  end
end


