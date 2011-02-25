#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../../config/environment'
else
  puts "Running from #{$0}"
end

require 'o_c_logger'



def add_vote(votesmart_bill, category, year = Date.today.year)
  bill_types = {"H Con Res"=>"hc", "H Res"=>"hr", "HR"=>"h", "HJR"=>"hj", "H J Res"=>"hj", "S J Res"=>"sj", "S Con Res"=>"sc", "S"=>"s", "S Res"=>"sr"}
  
  if m = /([A-Za-z\s]+)?\s+(\d+)/.match(votesmart_bill.billNumber)
    if m[1] and m[2]
      case m[1]
      when 'H Amdt'
      when 'S Amdt'
        a_number = (m[1] == 'H Amdt') ? "h#{m[2]}" : "s#{m[2]}"
        amdt = Amendment.find(:first, :conditions => ["number = ? AND date_part('year', offered_datetime)=?", a_number, year])
        if amdt
          amdt.key_vote_category = category
          amdt.save
        end
      when 'PN'
        #I dunno
      else
        oc_bill = Bill.find_by_ident("#{Settings.default_congress}-#{bill_types[m[1]]}#{m[2]}")
        if oc_bill
          oc_bill.key_vote_category = category
          oc_bill.save
        end
      end
    end
  end
end

year = Date.today.year

categories = GovKit::VoteSmart::BillCategory.find(year, nil)
categories.each do |c|
  OCLogger.log "Got category: #{c['name']}"
  
  pc = PvsCategory.find_or_create_by_name(c['name'])
  pc.pvs_id = c['categoryId']
  pc.save
  
  bills = GovKit::VoteSmart::Bill.find_by_category_and_year_and_state(pc.pvs_id, year, nil)

  bill = bills.bill
  if bill.kind_of? Array
    bill.each { |b| add_vote(b, pc, year) } 
  elsif bill.kind_of? GovKit::VoteSmart::Bill::Bill
    add_vote(bill, pc, year)
  end
end


    