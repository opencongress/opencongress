#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../config/environment'
require 'ostruct'

class Object
  def if_not_nil
    if block_given? && !nil?
      yield self
    else
      self
    end
  end
end

file = File.open(File.dirname(__FILE__) + "/../parsed_reports.txt")
file.readline #skip
lines = file.readlines.map { |l| l.chomp.split(/\t/, -7) }

structs = lines.map do |elms|
  o = OpenStruct.new
  o.index = elms[0].to_i
  o.title = elms[1]
  o.chamber = elms[2]
  o.reportname = elms[3]
  o.dbname = elms[4].to_i
  o.person = elms[5]
  o.committee = elms[6]
  o.bill = elms[7]
  o
end

structs.each do |s|
  #Bill
  report_number = s.reportname.match(/(\d.*)/).if_not_nil{|m| m.captures[0].to_i}
  next if report_number.nil?
  bill_id = nil
  unless s.bill == ""

    bill_type, num = s.bill.match(/(\D*)(\d+)/).captures
    s_type = Bill.long_type_to_short(bill_type)
    num = num.to_i
    
    if s_type.nil?
      s_type = (s.chamber == "house" ? "h" : "s")
    end

    bill = Bill.find_by_bill_type_and_number(s_type, num)
    
    if bill.nil?
      puts "#{s_type}#{num} not found "
    else
      bill_id = bill.id
    end
  end
  
  # Person
  name = s.person.match(/([A-Z\-\s]+)/).if_not_nil {|md| md.captures[0] }
  state = s.person.match(/of (.*)$/).if_not_nil { |md| State.abbrev_for(md.captures[0]) }
  first, last = name.match(/(\w+)\s(.+)/).if_not_nil {|md| md.captures}
  
  next if [name, state, first, last].any?(&:nil?)
  congress = s.dbname
  
  if state.nil? && last.nil?
    ps = Person.find_all_by_last_name_ci(name).select { |p| p.congress? congress }
  elsif last.nil? && !state.nil?
    ps = Person.find_all_by_last_name_ci_and_state(name, state).select { |p| p.congress? congress }
  elsif state.nil? && !last.nil?
    ps = Person.find_all_by_first_name_ci_and_last_name_ci(first,last).select { |p| p.congress? congress }
  else
    ps = Person.find_all_by_first_name_ci_and_last_name_ci_and_state(first,last,state).select { |p| p.congress? congress }
  end
  
  if s.chamber == "house"
    ps = ps.select { |p| p.representative? congress }
  end
  
  if s.chamber == "senate"
    ps = ps.select { |p| p.senator? congress }
  end
  
  person_id = nil
  
  if ps.nil? || ps.empty? || ps.size > 1
    puts "#{s.person} #{name} #{state} #{first} #{last}" 
    puts ps.size
  else
    person_id = ps[0].id
  end
  
  people_name = "#{s.chamber} #{s.committee}"
  comm = Committee.find_by_people_name_ci(people_name) || Committee.find_by_name_ci(people_name) || Committee.find_by_bill_name_ci(people_name)
  committee_id = nil

  if comm.nil?
    puts "Committee: #{s.num} #{people_name.inspect}"
  else
    committee_id = comm.id
  end
  
  cr = CommitteeReport.find_or_initialize_by_name_and_index(s.reportname, s.index)
  cr.title = s.title
  cr.congress = congress
  cr.number = report_number
  cr.kind = s.chamber
  cr.person_id = person_id unless person_id.nil?
  cr.bill_id = bill_id unless bill_id.nil?
  cr.committee_id = committee_id unless committee_id.nil?
  cr.save
end

