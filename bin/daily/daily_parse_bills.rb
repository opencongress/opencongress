#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../../config/environment'
else
  puts "Running from #{$0}"
end

require File.dirname(__FILE__) + '/../../app/models/action'

#This file is not intended to be run standalone.  If you do so, you
#will have inconsistent bills and amendments.

require 'rexml/document'
require 'ostruct'
require 'date'
require 'yaml'


PATH = GOVTRACK_DATA_PATH + "/bills"

class NoUpdateException < StandardError
end

committees = {}
related_bills = {}
subjects = {}

# prepare a has for later saving of subjects
subjects = Subject.find(:all).inject({}) do |hash, subject|
  hash[subject.term] ||= subject
  hash
end
subject_count = 0

force_parse = ENV['FORCE_ALL'] == 'true' ? true : false

# get the list of bill files we're going to parse
bill_files = Dir.new(PATH).entries.select { |f| f.match(/(.*).xml/) }
i = 0
bill_files.each do |f|
  Bill.transaction { 
    #Bills that need to be (re)parsed
    i += 1

    filename = "#{PATH}/#{f}"
    file = File.open(filename)
    doc = REXML::Document.new file
    es = doc.elements
    puts "Parsing file: #{filename} (#{i} of #{bill_files.size})"

    bill = nil
  
    begin
      es.each("bill") do |e|
        os = OpenStruct.new(e.attributes)
        os.bill_type = e.attributes["type"]
      
        number = os.number.to_i
        session = os.session.to_i
        bill_type = os.bill_type
        b = Bill.find_or_create_by_number_and_session_and_bill_type(number, session, bill_type)
      
        updated = Time.parse(os.updated)
        if (b.updated && b.updated == updated && !force_parse) 
          raise NoUpdateException, "Skipping bill...already parsed, no new info."
        end
      
        b.updated = updated
        b.introduced = os.introduced
        b.pl = os.pl unless os.pl == ''
        b.sponsor_id = os.sponsor.to_i
      
        if b.lastaction.nil? || b.lastaction != os.lastaction.to_i
          b.lastaction = os.lastaction.to_i
        end
      
        unless os.topresident.nil?
          b.topresident_date = os.topresident.date
          b.topresident_datetime = DateTime.parse(os.topresident.datetime)
        end
        b.save
        bill = b
      end
    
      es.each("bill/introduced") do |e|
        attrs = e.attributes
        act = BillAction.find_or_initialize_by_action_type_and_bill_id("introduced", bill.id)
        time = attrs["date"].to_i
        act.datetime = Time.at(time).utc.to_date #could be a problem
        if act.date.nil? || act.datetime.nil? || time != act.date
          act.date = time
          if attrs["datetime"]
            act.datetime = DateTime.parse(attrs["datetime"])
          end
        end
        if time != bill.introduced
          bill.introduced = time
        end
        act.save
      end

      es.each("bill/sponsor") do |e| 
        id = e.attributes["id"].to_i
        s = Person.find_by_id(id)
        if s
          bill.sponsor = s
        end
      end

      cosponsors = []
      es.each("bill/cosponsors/cosponsor") do |e| 
        id = e.attributes["id"].to_i
        cosponsors << BillCosponsor.find_or_create_by_bill_id_and_person_id(bill.id, id)
      end
      bill.bill_cosponsors = cosponsors
      bill.save

      es.each("bill/titles/title") do |e|
        as = e.attributes
        t = BillTitle.find_or_create_by_bill_id_and_title_type_and_as_and_title(bill.id, as["type"], as["as"], e.text)
      end

      es.each("bill/actions") do |all|
        action_times = []
        all.each_element do |e|
          attrs = e.attributes
          text = ''
          e.each_element("text") {|text_elem| text = text_elem.text}
        
          # hack because THOMAS/govtrack has bad data for this bill
          if text =~ /Sponsor introductory remarks on measure\. \(CR H1252\)/
            time = 1234396800
          else
            time = attrs["date"].to_i
          end
        
          action_times << time
          act = BillAction.find_or_initialize_by_bill_id_and_action_type_and_date_and_text(bill.id, e.name, time, text)
          if attrs["datetime"]
            # hack because THOMAS/govtrack has bad data for this bill
            if text =~ /Sponsor introductory remarks on measure\. \(CR H1252\)/
              act.datetime = '2009-02-12'            
            else
              act.datetime = DateTime.parse(attrs["datetime"])
            end
          else
            act.datetime = Time.at(time).utc.to_date #could be a problem
          end
          act.how = attrs["how"]
          act.where = attrs["where"]
          if e.name == "vote"
            act.vote_type = attrs["type"]
            act.roll_call_number = attrs["roll"]
          
            # see if we've already parsed the roll call
            roll_where = attrs["where"] == 'h' ? "house" : "senate"
            roll_call = RollCall.find_by_number_and_where(attrs["roll"], roll_where)
            act.roll_call = roll_call if roll_call and act.datetime.year == roll_call.date.year
          end
          if e.name = "topresident"
            bill.topresident_date = time
            bill.topresident_datetime = act.datetime
          end
          act.result = attrs["result"] 
          e.each_element("reference") { |ref| 
            act.action_references.find_or_create_by_label_and_ref(ref.attributes['label'], ref.attributes['ref'])
          }
        
          act.save
        end
        # set the lastaction time for the bill
        lastaction = action_times.sort.last
        if bill.lastaction != lastaction
          bill.lastaction = lastaction
        end
      end

      es.each("bill/committees/committee") do |e|
        as = e.attributes
        name = as["name"] || ''
        subcomm = as["subcommittee"] || ''
        comms = Committee.find_by_query(name, subcomm)
        if comms.empty?
          comm = Committee.new
          comm.name = name
          comm.subcommittee_name = subcomm
          comm.save
        elsif comms.size == 1
          comm = comms.first
        else
          next
        end
        bc = BillCommittee.find_or_create_by_bill_id_and_committee_id(bill.id, comm.id)
      end
    
      es.each("bill/relatedbills/bill") do |e|
        as = e.attributes
        reltype = as["type"]
        relnumber = as["number"].to_i
      
        related_bill = Bill.find_by_bill_type_and_number_and_session(reltype, relnumber, DEFAULT_CONGRESS)

        if related_bill.nil?
          # this bill has not been parsed yet; set the info in an array and add it after all the bills have been
          # parsed
          related_bills[[reltype, relnumber, as["relation"]]] = bill
        else
          bill_id = bill.id
          related_bill_id = related_bill.id
        
          br = BillRelation.find_or_initialize_by_bill_id_and_related_bill_id(bill_id, related_bill_id)
          br.relation = as["relation"]
          br.save
        end
      end


      es.each("bill/subjects/term") do |e|
        term = e.attributes["name"]
        if subjects[term]
          subject = subjects[term]
        else
          subject = Subject.find_or_create_by_term(term)
        
          subjects[term] = subject
        end
      
        bs = BillSubject.find_or_create_by_bill_id_and_subject_id(bill.id, subject.id)
        subject_count += 1
        puts "subject relationships saved: #{subject_count}" if subject_count % 100 == 0
      end

      es.each("bill/amendments/amendment") do |e|
        number = e.attributes["number"]
        a = Amendment.find_or_create_by_bill_id_and_number(bill.id, number)
        #we don't seem to have any use for amendments, is that correct?
      end

      es.each("bill/summary") do |e|
        #this sucks, but I can't find a better way
        summary = e.to_s.split /\n/
        bill.summary = summary[1..-2].join("")
        break #should only have one summary
      end
        
      bill.save 
      file.close
    rescue NoUpdateException => nue
      puts nue
      file.close
    rescue Exception => e
      puts e
      puts $!.backtrace
      puts "error in #{filename}"
    end
  }
end

# save all of the subjects to force their bill counts to be accurate
puts "Saving subjects"
count = 0
subjects.values.each do |s|
  count += 1
  puts "count: #{count}" if count % 100 == 0
  s.save 
end
puts "total subject count: #{count}"


# save any related bills that were not recognized during the parse
puts "Saving Related Bills"
count = 0
related_bills.keys.each do |rb|
  bill = related_bills[rb]
  
  related_bill = Bill.find_by_bill_type_and_number_and_session(rb[0], rb[1], DEFAULT_CONGRESS)
  if related_bill.nil?
    puts "Error! Unknown related bill: #{rb.inspect}"
  else
    br = BillRelation.find_or_initialize_by_bill_id_and_related_bill_id(bill.id, related_bill.id)
    br.relation = rb[2]
    br.save
  end
end
    
    
