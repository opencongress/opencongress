#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../config/environment'
end

file = File.dirname(__FILE__) + "/committee_names.tsv"

IO.foreach(file) do |line|
  line.chomp!
  bill_comm, bill_sub, people_comm, people_sub = line.gsub(/"/, "").gsub(/[ ]+/, " ").split(/\t/, -4).map { |elm| elm == "" ? nil : elm }  
  c = 
    Committee.find_by_name_and_subcommittee_name(bill_comm, bill_sub) || 
    Committee.find_by_name_and_subcommittee_name(people_comm, people_sub) || 
    Committee.find_by_name_and_subcommittee_name(bill_comm, people_sub) || 
    Committee.find_by_name_and_subcommittee_name(people_comm, bill_sub)

  if c.nil? 
    puts "#{[bill_comm, bill_sub, people_comm, people_sub].inspect}" 
  else
    c.bill_name = bill_comm
    c.bill_subcommittee_name = bill_sub
    c.people_name = people_comm
    c.people_subcommittee_name = people_sub
    c.save
  end
end
