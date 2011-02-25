#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../config/environment'
end

require 'hpricot'
require 'ostruct'

class Object
  def if_not_nil
    if block_given? && !nil?
      yield self
    else
      self
    end
  end
end

base_path = Settings.committee_reports_path

dirs = ["house", "senate", "conference", "joint"]

crs = CommitteeReport.find(:all).inject({}) do |hash, elm|
  hash[elm.name] ||= elm
  hash
end

count = 0

CommitteeReport.transaction {

  dirs.each do |dir|
    path = "#{base_path}/#{dir}/"
    puts path
    lines = File.open(path + "log.txt").readlines
    structs = lines.map do |l| 
      o = OpenStruct.new
      elms = l.chomp.split /\t/
      o.index = elms[0].to_i; o.title = elms[1]; o.reportname = elms[2];
      o.dbname = elms[3].to_i; 
      o.filename = "/#{elms[4][1..-1]}"
      o
    end
    
    structs.each do |o|
      count += 1
      congress = o.dbname.to_i

      next unless crs[o.reportname].nil?

      if !File.exist?(o.filename)
        puts "No #{o.filename}" 
        next
      end
      
      doc = Hpricot(open(o.filename)) rescue nil

      next if doc.nil?

      reported_at_arr = doc.search("center").select { |ele| ele.inner_text =~ /ordered to be printed/i } 
      reported_at_arr = doc.search("td").select { |ele| ele.inner_text =~ /ordered to be printed/i } if reported_at_arr.empty?
      reported_at_arr = doc.search("p").select { |ele| ele.inner_text =~ /ordered to be printed/i } if reported_at_arr.empty?
      reported_at = nil
      reported_at = Date.parse(reported_at_arr.first.inner_html).to_time unless reported_at_arr.empty?
      puts "#{o.index} - #{reported_at}"

      ps = doc/:p
      person = nil
      committee = nil
      bill = nil
      
      ps.each do |p|
        md = p.inner_html.gsub(/\s+/, " ").match(/accompany (.*?)\]/)
        unless md.nil?
          bill = md.captures[0]
          break
        end
      end
      
      italics = ps/"center/em"
      italics.each do |elm|
        md = elm.inner_html.gsub(/\s+/, " ").match(/^\S+\s(.*?)[, ]+from\sthe\s([a-zA-Z\s]*)(.*?)(s.*ubmitted|$)/i)
        unless md.nil?
          person, committee = md.captures
          break
        end
      end
      
      if person.nil? || committee.nil?
        tables = doc/:table
        trs = tables/:tr
        if trs.respond_to?(:/) && !trs.instance_of?(Array)
          tds = trs/:td
          tds.each do |elm|
            md = elm.inner_html.gsub(/\s+/, " ").match(/^\S+\s(.*?)[, ]+from\sthe\s(.*)[, ]+(s.*ubmitted|$)/i)
            unless md.nil?
              person, committee = md.captures
              committee = committee.sub(/,$/, "")
              break
            end
          end
        end
      end

      
      #bill
      unless bill.nil?
        unless bill.empty?
          bill_type, num = bill.match(/(\D*)(\d+)/).captures
          s_type = Bill.long_type_to_short(bill_type)
          num = num.to_i
          bill = nil
          bill = Bill.find_by_bill_type_and_number(s_type, num)
        else
          bill = nil
        end
      end

      #committee
      if !dir.nil? && !committee.nil?
        people_name = "#{dir} #{committee}"
        committee = nil
        cs = Committee.find_by_query(people_name, '')
        if cs.size == 1
          committee = cs[0]
        end
      end

      #person
      unless person.nil?
        name = person.match(/([A-Z\-\s]+)/).if_not_nil {|md| md.captures[0] }
        state = person.match(/of (.*)$/).if_not_nil { |md| State.abbrev_for(md.captures[0]) }
        first, last = name.match(/(\w+)\s(.+)/).if_not_nil {|md| md.captures}
        person = nil
      
        if state.nil? && last.nil?
          peeps = Person.find_all_by_last_name_ci(name).select { |p| p.congress? congress }
        elsif last.nil? && !state.nil?
          peeps = Person.find_all_by_last_name_ci_and_state(name, state).select { |p| p.congress? congress }
        elsif state.nil? && !last.nil?
          peeps = Person.find_by_first_name_ci_and_last_name_ci(first,last).select { |p| p.congress? congress }
        else
          peeps = Person.find_all_by_first_name_ci_and_last_name_ci_and_state(first,last,state).select { |p| p.congress? congress }
        end
        
        if dir == "house"
          peeps = peeps.select { |p| p.representative_for_congress? congress }
        end
        
        if dir == "senate"
          peeps = peeps.select { |p| p.senator_for_congress? congress }
        end
        
        if peeps.nil? || peeps.empty? || peeps.size > 1
#          puts "no match: #{person} #{name} #{state} #{first} #{last}" 
#          puts peeps.size
        else
          person = peeps[0]
        end
      end
      
      cr = CommitteeReport.find_by_name(o.reportname)
      if cr.nil? && !committee.nil?
        puts "#{o.reportname}"
        cr = CommitteeReport.new
        cr.name = o.reportname
        cr.index = o.index
        cr.title = o.title
        cr.number = o.reportname.match(/(\d.*)/).if_not_nil{|m| m.captures[0].to_i}
        cr.bill = bill
        cr.reported_at = reported_at
        cr.committee = committee
        cr.kind = dir
        cr.congress = o.dbname.to_i
        cr.person = person
        cr.save
      end
    end
  end

}
