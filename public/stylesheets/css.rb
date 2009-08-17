#!/usr/bin/ruby

File.open("master.css", "r+") do |file|
  lines = file.readlines
  lines.each do |sub|
    unless sub.include? "@import"
    sub.gsub!(/(url\(['"]?)/){ |sub| $1 + 'http://s3.amazonaws.com/OpenCongressImages/stylesheets/'}
    end
  end
  file.pos = 0
  file.print lines
  file.truncate(file.pos)
end