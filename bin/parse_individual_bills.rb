#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../config/environment'

#Have to do this because rails doesn't like multiple models in the same file
require  File.dirname(__FILE__) + '/../app/models/action'

require 'rexml/document'
require 'date'

PATH = Settings.govtrack_data_path + "/#{Settings.default_congress}/bills"

#hash of people, indexed by id
people = Person.find(:all).inject({}) { |h,p| h[p.id] = p; h }

count = 0

bills = Bill.find(:all)

bills.each do |bill|
  filename = "#{PATH}/#{bill.bill_type}#{bill.number}.xml"
  file = File.open(filename)
  doc = REXML::Document.new file
  es = doc.elements
  cosponsors = []
  puts count if count % 100 == 0
  count += 1

  begin
    es.each("bill/introduced") do |e|
      attrs = e.attributes
      act = BillAction.new
      act.action_type = "introduced"
      act.bill = bill
      time = attrs["date"].to_i
      act.date = time
      if attrs["datetime"]
        act.datetime = DateTime.parse(attrs["datetime"])
      else
        act.datetime = Time.at(time).utc.to_date #could be a problem
      end
      act.save
    end

    es.each("bill/cosponsors/cosponsor") do |e| 
      person = people[e.attributes["id"].to_i]
      cs = BillCosponsor.new
      cs.bill = bill
      cs.person = person
      cs.save
    end

    es.each("bill/titles/title") do |e|
      as = e.attributes
      t = BillTitle.new
      t.bill = bill
      t.title_type = as["type"]
      t.as = as["as"]
      t.title = e.text
      t.save
    end

    #es.each("bill/actions/action") do |e|
    #     attrs = e.attributes
    #     act = BillAction.new
    #     act.action_type = "action"
    #     act.bill = bill
    #     act.date = DateTime.parse(attrs["datetime"])
    #     e.each_element("text") {|e| act.text = e.text} 
    #     act.save
    #   end

    es.each("bill/actions") do |all|
      all.each_element do |e|
        attrs = e.attributes
        act = BillAction.new
        act.action_type = e.name
        act.bill = bill
        time = attrs["date"].to_i
        act.date = time
        if attrs["datetime"]
          act.datetime = DateTime.parse(attrs["datetime"])
        else
          act.datetime = Time.at(time).utc.to_date #could be a problem
        end
        act.how = attrs["how"]
        act.where = attrs["where"]
        if e.name == "vote"
          act.vote_type = attrs["type"]
        end
        act.result = attrs["result"]
        e.each_element("text") {|e| act.text = e.text} 
        act.save
      end
    end

    es.each("bill/committees/committee") do |e|
      as = e.attributes
      name, subcomm = as["name"], as["subcommittee"]
      comm = Committee.find_by_name_and_subcommittee_name(name, subcomm)
      if comm.nil?
        comm = Committee.new
        comm.name = name
        comm.subcommittee_name = subcomm
        comm.save
      end
      bc = BillCommittee.new
      bc.bill = bill
      bc.committee = comm
      bc.save
    end

    es.each("bill/relatedbills/bill") do |e|
      as = e.attributes
      reltype = as["type"]
      relnumber = as["number"].to_i
      br = BillRelation.new
      br.bill = bill
      br.relation = as["relation"]
      br.related_bill_id = Bill.find_by_bill_type_and_number(reltype, relnumber).id rescue nil
      if br.related_bill_id.nil?
        #what to do here?  these are bills we do not have that are
        #related
      end
      br.save
    end

    es.each("bill/subjects/term") do |e|
      term = e.attributes["name"]
      subject = Subject.find_by_term term
      if subject.nil?
        subject = Subject.new
        subject.term = term
        subject.save
      end
      bs = BillSubject.new
      bs.bill = bill
      bs.subject = subject
      bs.save
    end

    es.each("bill/amendments/amendment") do |e|
      #create empty amendments for now, but with the correct number.
      #will need a separate amendment parser
      a = Amendment.new
      a.number = e.attributes["number"]
      a.bill = bill
      a.save
    end

    es.each("bill/summary") do |e|
      #this sucks, but I can't find a better way
      summary = e.to_s.split /\n/
      bill.summary = summary[1..-2].join("")
      break #should only have one summary
    end
    bill.save
    file.close
  rescue 
    puts $!.inspect
    puts "error in #{filename}"
  end
end
