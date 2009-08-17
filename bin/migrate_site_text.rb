#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../../config/environment'
else
  puts "Running from #{$0}"
end

# make a holder class for site text from the dev database
class DevSiteText < ActiveRecord::Base
  set_table_name  "site_texts"

  establish_connection "development"
end

old_site_text = DevSiteText.find_all

old_site_text.each do |ost|
  st = SiteText.find_by_text_type(ost.text_type)
  
  unless st
    st = SiteText.new
    st.text_type = ost.text_type
    st.text = ost.text
    st.save
  else
    if st.updated_at < ost.updated_at
      st.text = ost.text
      st.save
    end
  end
end


