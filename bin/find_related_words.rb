#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../config/environment'

grouped = BillSubject.find_all.map { |c| [c.subject_id, c.bill_id] }.group_by{|i| i[1]} #subject ids grouped into a hash by bill_id

hash = {}
count = 0

grouped.values.each do |array|
  subjects = array.map { |s| s[0] }  
  count += 1
  puts "done with #{count}" if (count % 100) == 0
  stuff = []
  #the next two lines find all the combinations of subject/subject
  #association for the list.  The sort is there because we want [1,2]
  #and [2,1] to be the same, and the to_set might as well be a uniq I
  #suppose
  subjects.each { |s| stuff.concat(subjects.map { |h| [s,h].sort }) } 
  stuff.to_set.each do |elm|
    hash[elm] ||= 0
    hash[elm] += 1
  end
end

puts "About to start words.txt"
File.open("words.txt", "w+") do |f|
  f.puts "word, word, count"

  ordered = hash.keys.sort_by { |k| hash[k] }
  ordered.each do |w|
    f.puts "#{w[0]}, #{w[1]}, #{hash[w]}"
  end
end
