#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../config/environment'
end

require 'hpricot'
require 'generator'
require 'open-uri'
require 'fileutils'

$base_path = COMMITTEE_REPORTS_PATH
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

class Generator
  attr_accessor :i
end

class Parser
  attr_reader :gen, :congress, :printable_base

  def initialize
    @gen = proc do |g| 
      g.i = 1 if g.i.nil?
      while true
        g.yield g.i
        g.i += 50
      end
    end
    @congress = DEFAULT_CONGRESS
    @printable_base = "http://thomas.loc.gov/cgi-bin/cpquery/T?&report=%s&dbname=%s&"
  end

  def parse(url_base, type)
    reports = []
    log = File.open "#{$base_path}/#{type}/log.txt", "w+"

    Generator.new(&gen).each do |i|
      url = url_base % [congress, congress]
      current_url = url + i.to_s
      puts current_url
      doc = Hpricot(open(current_url))
      reports = ((doc/:table/:tr)).select { |elm| (elm/:td).size == 5 }
      reports.each do |tr|
        entries = tr/:td
        num = entries[0].inner_html.to_i
        name = entries[1].inner_html
        md = (entries[2]/:a).to_html.match(/report=(.*?)\&/)
        next if md.nil?
        reportname, dbname = md.captures[0].split(/\./)
        report_url = (printable_base % [reportname, dbname])
        filename = "#{$base_path}/#{type}/#{num}.#{reportname}.#{dbname}.html" 
        log.puts "#{num}\t#{name}\t#{reportname}\t#{dbname}\t#{filename}"
        log.flush
        unless File.exists? filename
          report = Hpricot(open(report_url))
          contents = (report/'div[@id="content"]')
          File.open(filename, "w+") do |f|
            f.puts "<html>"
            f.puts contents.first.to_html
            f.puts "</html>"
          end
        end #unless
      end #reports.each
      if reports.size < 50
        break
      end
    end
    log.close
  end
end

p = Parser.new

p.parse(house_reports_url, "house")
p.parse(senate_reports_url, "senate")
p.parse(conference_reports_url, "conference")
p.parse(joint_reports_url, "joint")
