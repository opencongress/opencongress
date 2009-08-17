#!/usr/bin/env ruby
require 'dbi'

dbh = DBI.connect("dbi:Pg:opencongress_development:localhost", "opencongress", "pcf123")

lines = File.open("words.txt").readlines.map { |w| w.chomp }

lines.shift


fields = lines.map { |l| l.split(/,\s*/).map { |s| s.to_i } }

count = 0

dbh.do("BEGIN;")
sth = dbh.prepare("INSERT INTO subject_relations (subject_id, related_subject_id, relation_count) values (?,?,?);")
fields.each do |triple|
  word, other_word, relation_count = triple
  next if word == other_word
  count += 1
  puts "done with #{count}" if count % 1000 == 0
    sth.execute(word,other_word,relation_count)
end
dbh.do("COMMIT;")
