#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../../config/environment'
else
  puts "Running from #{$0}"
end

class NoUpdateException < StandardError
end

PATH = Settings.govtrack_data_path + "/#{Settings.default_congress}/rolls"

force_parse = ENV['FORCE_ALL'] == 'true' ? true : false

roll_files = Dir.new(PATH).entries.select { |f| f.match(/(.*).xml$/) }
i = 0  
curr_bill = 0
roll_files.each do |f| 
  curr_bill += 1
  puts "Parsing roll call file: #{PATH}/#{f} (Bill #{curr_bill} of #{roll_files.size})"

  rollFile = File.open("#{PATH}/#{f}", "r")
  
  doc = REXML::Document.new rollFile
  es = doc.elements

  roll = nil
  RollCall.transaction {  
    begin
      es.each("roll") do |e|
        os = OpenStruct.new(e.attributes)
        os.date = Time.parse(os.datetime)
        updated = Time.parse(os.updated)
      
        roll = RollCall.find_or_initialize_by_date_and_number(os.date, os.roll.to_i)
        #puts "O: #{roll.updated}; N: #{updated}"
        if (roll.updated && roll.updated == updated && !force_parse) 
          raise NoUpdateException, "Skipping roll call...already parsed, no new info."
        end
        roll.updated = updated
        roll.where = os.where

        roll.ayes = os.aye
        roll.nays = os.nay
        roll.abstains = os.nv
        roll.presents = os.present
      
        roll.save
      end
    
      es.each("roll/type") do |e|
        roll.roll_type = e.text
      end
    
      es.each("roll/question") do |e|
        roll.question = e.text
      end
    
      es.each("roll/required") do |e|
        roll.required = e.text
      end
    
      es.each("roll/result") do |e|
        roll.result = e.text
      end

      es.each("roll/bill") do |e|
        os = OpenStruct.new(e.attributes)
        os.bill_type = e.attributes["type"]
      
        bill = Bill.find_by_session_and_bill_type_and_number(os.session, os.bill_type, os.number)
        if bill
          roll.bill = bill
        
          if (bill.last_vote_date && bill.last_vote_date != 0)
            bill.last_vote_date = roll.date.to_i if (roll.date.to_time > Time.at(bill.last_vote_date))
          else 
            bill.last_vote_date = roll.date.to_i
          end
          bill.save
        end
      end
    
      es.each("roll/amendment") do |e|
        os = OpenStruct.new(e.attributes)
      
        amendment = Amendment.find_by_bill_id_and_number(roll.bill.id, os.number)
        if amendment
          roll.amendment = amendment
        end
      end
        
      es.each("roll/voter") do |e|
        os = OpenStruct.new(e.attributes)
        os.voter_id = e.attributes["id"]

        person = Person.find_by_id(os.voter_id)
        if person
          rcv = RollCallVote.find_or_initialize_by_roll_call_id_and_person_id(roll.id, person.id)
          rcv.vote = os.vote
          rcv.save
        end
      end
    
      roll.save

      # see if we can find the action associated with this roll call
      action = Action.find(:first, 
                           :conditions => ["action_type='vote' AND \"where\" = ? AND roll_call_number = ? AND date_part('year', datetime) = ?", 
                                           roll.where[0,1], roll.number, roll.date.year])
      if action and action.roll_call.nil?
        action.roll_call = roll
        action.save
      end
    rescue NoUpdateException
      puts "No update: #{$!}"      
    end
  }
end

Person.calculate_and_save_party_votes
