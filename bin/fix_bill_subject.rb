#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../config/environment'
require "dbi"

require 'rexml/document'
require 'date'

PATH = Settings.govtrack_data_path + "/#{Settings.default_congress}/bills"

bills = Bill.find_all

count = 0

puts "subject start"
subjects = Subject.find_all.inject({}) { |hash,s| hash[s.term] ||= s; hash }
puts "bill subject start"
bill_subjects = BillSubject.find_all.inject({}) { |hash,bs| hash[[bs.bill_id, bs.subject_id]] ||= bs; hash}

puts "parsing start"
stuff = []

bills.each do |bill|
  filename = "#{PATH}/#{bill.bill_type}#{bill.number}.xml"
  file = File.open(filename)
  doc = REXML::Document.new file
  es = doc.elements

  begin
    es.each("bill/subjects/term") do |e|
      count += 1
      term = e.attributes["name"]
      subject = subjects[term] 
      if subject.nil?
        subject = Subject.find_or_create_by_term(term)
        subjects[term] = subject
      end
      if bill_subjects[[bill.id, subject.id]].nil?
        #        bs = BillSubject.find_or_create_by_bill_id_and_subject_id(bill.id, subject.id) 
#        bs = BillSubject.new
#        bs.bill_id = bill.id
#        bs.subject_id = subject.id
        puts "done: #{count}" if ((count % 1000) == 0)
        stuff.push [bill.id, subject.id]
      end
    end
    file.close
  rescue 
    puts $!.inspect
    puts "error in #{filename}"
  end
end

File.open("inserts.sql", "w+") do |f|
  stuff.each do |pair|
    bill_id = pair[0]
    subject_id = pair[1]
    f.puts "INSERT INTO bill_subjects (bill_id, subject_id) VALUES (#{bill_id},#{subject_id});"
  end
end
