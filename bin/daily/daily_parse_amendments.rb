#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../../config/environment'
else
  puts "Running from #{$0}"
end

require File.dirname(__FILE__) + '/../../app/models/action'
require 'rexml/document'
require 'date'

PATH = Settings.govtrack_data_path + "/#{Settings.default_congress}/bills.amdt"

amendments = Amendment.find(:all, :include => :bill, :conditions => [ "bills.session = ?", Settings.default_congress ])
count = 0
a_num = 0
amendments.each do |amdt|
  a_num += 1
  filename = "#{PATH}/#{amdt.number}.xml"
  puts "Parsing #{filename} (#{a_num} of #{amendments.size})"
  
  file = File.open(filename)
  doc = REXML::Document.new file
  
  root = doc.root

  updated = Time.parse(doc.root.attributes["updated"])
  unless (amdt.updated && amdt.updated == updated) 
    amdt.updated = updated
    amdt.retreived_date = doc.root.attributes["retreived_date"].to_i
    root.each_element("status") do |e| 
      as = e.attributes
      amdt.status = e.text
      amdt.status_date = Time.parse(as["datetime"]).to_i
      amdt.status_datetime = DateTime.parse(as["datetime"])
    end
    root.each_element("offered") do |e|
      as = e.attributes
      amdt.offered_date = Time.parse(as["datetime"]).to_i
      amdt.offered_datetime = DateTime.parse(as["datetime"])
    end
    root.each_element("description") {|e| amdt.description = e.text}
    root.each_element("purpose") {|e| amdt.purpose = e.text}
    root.each_element("actions/*") do |e|
      attrs = e.attributes
      date = Time.parse(attrs["datetime"]).to_i
      act = AmendmentAction.find_or_initialize_by_amendment_id_and_date(amdt.id, date)
      e.each_element("reference") do |e|
        aref = e.attributes["ref"]
        ref = Refer.find_or_initialize_by_ref(aref)
        ref.label = e.attributes["label"]
        ref.action = act
        ref.save
      end
      act.action_type = e.name
      if e.name == "vote"
        act.result = attrs["result"]
        act.how = attrs["how"]
      end
      e.each_element("text") { |e| act.text = e.text }
      act.date = date
      act.datetime = DateTime.parse(attrs["datetime"])
      act.amendment = amdt
      act.save
    
    end
    
    amdt.save
  else
    puts "Skipping...no new info."
  end

  file.close
end
