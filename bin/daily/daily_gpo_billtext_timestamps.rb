#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../../config/environment'
else
  puts "Running from #{$0}"
end

require 'rubygems'
require 'hpricot'
require 'open-uri'

url  = "http://frwebgate.access.gpo.gov/cgi-bin/BillBrowse.cgi?dbname=111_cong_bills&wrapperTemplate=all111bills_wrapper.html&billtype=all"

begin
  doc = Hpricot(open(url))
  
  doc.search("//b").each do |bill_title|
    bill_long_type, number, text_version = bill_title.inner_html.split(" ")
    text_version.gsub!(/[\(\)]/, "")
    
    GpoBilltextTimestamp.find_or_create_by_session_and_bill_type_and_number_and_version(
          Settings.default_congress, Bill.long_type_to_short(bill_long_type), number, text_version)
  end
  
rescue Exception => e
  puts "Error parsing GPO #{e}"
end