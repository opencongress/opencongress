#!/usr/bin/env ruby
cmd = "./s3sync.rb -r /Users/Scott/Pictures/elf_yourself/ spatten_test:elf --verbose"
5.times do 
  start_time = Time.now
  `#{cmd}`
  end_time = Time.now
  puts "elapsed time: #{end_time - start_time}"
end