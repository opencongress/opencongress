#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../config/environment'
end

require 'hpricot'
require 'open-uri'
require 'fileutils'

$base_path = Settings.committee_reports_path
types = ["#{$base_path}/house","#{$base_path}/senate","#{$base_path}/conference","#{$base_path}/joint"]
types.each do |t|
  unless FileTest.directory?(t)
    Dir.mkdir(t)
  end
end

house_reports_url = "http://thomas.loc.gov/cgi-bin/cpquery/L?cp%d:list/cp%dch.lst:"
senate_reports_url = "http://thomas.loc.gov/cgi-bin/cpquery/L?cp%d:./list/cp%dcs.lst:"
conference_reports_url = "http://thomas.loc.gov/cgi-bin/cpquery/L?cp%d:./list/cp%dco.lst:"
joint_reports_url = "http://thomas.loc.gov/cgi-bin/cpquery/L?cp%d:./list/cp%dcj.lst:"

class Parser
  attr_reader :gen, :congress, :printable_base, :rows_per_page

  def initialize
    @congress = Settings.default_congress
    @printable_base = "http://thomas.loc.gov/cgi-bin/cpquery/T?&report=%s&dbname=%s&"
    @rows_per_page = 50
  end

  def parse(url_base, type)
    reports = []
    log = File.open "#{$base_path}/#{type}/log.txt", "w+"
    
    entry_num = 0

    # This loops through the pages of results from THOMAS.
    # We'll exit when we see less than 50 entries on a given page.
    while true
      url = url_base % [congress, congress]
      current_url = url + entry_num.to_s
      puts current_url
      doc = Hpricot(open(current_url))
      
      # We're looking at each row of the HTML table on the reports index page
      all_reports = ((doc/:table/:tr))
      reports = all_reports.select { |elm| (elm/:td).size == 5 }

      reports.each do |tr|
        entries = tr/:td
        entry_num = entries[0].inner_html.to_i
        name = entries[1].inner_html
        md = (entries[2]/:a).to_html.match(/report=(.*?)\&/)
        next if md.nil?

        reportname, dbname = md.captures[0].split(/\./)
        report_url = (printable_base % [reportname, dbname])
        filename = "#{$base_path}/#{type}/#{entry_num}.#{reportname}.#{dbname}.html" 
        log.puts "#{entry_num}\t#{name}\t#{reportname}\t#{dbname}\t#{filename}"
        log.flush
        unless File.exists? filename
          begin
            report = Hpricot(open(report_url))
            contents = (report/'div[@id="content"]')
            unless contents.first.nil?
              File.open(filename, "w+") do |f|
                f.puts "<html>"
                f.puts contents.first.to_html
                f.puts "</html>"
              end
            end
          rescue
            puts "Bad HTML for report: #{report_url}. Skipping..."  
          end
        end #unless
      end #reports.each
      
      # If we ended on #46, let's fetch #47 next time around.
      entry_num += 1;
      
      if all_reports.size < rows_per_page
        break
      end

    end # while true
    
    log.close
  end
end

p = Parser.new

p.parse(house_reports_url, "house")
p.parse(senate_reports_url, "senate")
p.parse(conference_reports_url, "conference")
p.parse(joint_reports_url, "joint")
