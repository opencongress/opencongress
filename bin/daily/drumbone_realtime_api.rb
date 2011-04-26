#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../../config/environment'
else
  puts "Running from #{$0}"
end

require 'json'
require 'open-uri'
require 'o_c_logger'

bill_types = {"hcres"=>"hc", "hres"=>"hr", "hr"=>"h", "hjres"=>"hj", "sjres"=>"sj", "scres"=>"sc", "s"=>"s", "sres"=>"sr"}

begin
  roll_doc = JSON.parse(open("http://drumbone.services.sunlightlabs.com/v1/api/rolls.json?apikey=#{ApiKeys.sunlightlabs_key}&order=voted_at&sort=desc").read)
  
  rolls = roll_doc['rolls']
  
  rolls.each do |r|
    #puts r.inspect
    
    # OCLogger.log "Year: #{r["year"]}"
    # OCLogger.log "Number: #{r["number"]}"
    # OCLogger.log "Chamber: #{r["chamber"]}"
    # OCLogger.log "Result: #{r["result"]}"
    # OCLogger.log "Date: #{r["voted_at"]}"
    # OCLogger.log "Type: #{r["type"]}"
    # OCLogger.log "Question: #{r["question"]}"
    # OCLogger.log "Chamber: #{r["chamber"]}"
    # OCLogger.log "Required: #{r["required"]}"

    roll_call = RollCall.find(:first, :conditions => ["date_part('year', date)=? AND \"where\"=? AND number=?", 
                                                      r['year'], r['chamber'], r['number']])
                                                      
    if roll_call.nil?
      OCLogger.log "New roll call (#{r['chamber']}#{r['number']})"
    
      roll_call = RollCall.new
      roll_call.number = r['number']
      roll_call.where = r['chamber']
      roll_call.date =  Time.parse(r['voted_at'])
      roll_call.roll_type = r['type']
      roll_call.question = r['question']
      roll_call.where = r['chamber']
      roll_call.required = r['required']
      roll_call.result = r['result']
      
      roll_call.nays = r['vote_breakdown']['nays']
      roll_call.ayes = r['vote_breakdown']['ayes']
      roll_call.abstains = r['vote_breakdown']['not_voting']
      roll_call.presents = r['vote_breakdown']['present']
      
      # not setting 'updated' so the normal bill parser will get it

      unless r['bill'].nil?
        bill = Bill.find_by_ident("#{r['bill']['session']}-#{bill_types[r['bill']['type']]}#{r['bill']['number']}")
        
        roll_call.bill = bill if bill
      end
      
      roll_call.save
      
      r['voter_ids'].keys.each do |v|
        p = Person.find_by_bioguideid(v)
        
        if p
          rcv = RollCallVote.find_or_create_by_roll_call_id_and_person_id(roll_call.id, p.id)
          rcv.vote = r['voter_ids'][v]
          rcv.save
        end
      end
    else
      OCLogger.log "Roll call exists (#{r['chamber']}#{r['number']})"
    end
  end
rescue
  puts "Error getting real-time roll calls:#{$!}\n\n #{$!.backtrace.join("\n")}"
end