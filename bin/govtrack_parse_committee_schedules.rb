#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../config/environment'
end

require 'rexml/document'

path = Settings.govtrack_data_path + "/#{Settings.default_congress}/committeeschedule.xml"

class CommitteeScheduleListener

  def initialize
    #nop
  end

  def xmldecl(*args)
    #nop
  end

  def tag_start(name, attrs)
    case name
    when "committee-schedule"
      #nop
    when "meeting"
      date = Time.at(attrs["date"].to_i)
      time = attrs["time"]
      where = attrs["where"]
      next if attrs['committee'].nil?
      committee, subcommittee = attrs[ "committee" ].split(/\s+--\s+/)
      subcommittee ||= ''
      comms = Committee.find_by_query(committee, subcommittee)
      if comms.empty?
        c = 
          Committee.find_by_name_and_subcommittee_name(committee, subcommittee) || 
          Committee.find_by_name(committee)

      elsif comms.size == 1
        c = comms[0]
      end

      if c.nil? #I have no idea what to do here.
        puts "Error finding: #{attrs["committee"]}" 
      else
        @meeting = CommitteeMeeting.find_or_create_by_committee_id_and_meeting_at(c.id, date)
        @meeting.where = where
      end
    when "bill"
      session = attrs["session"].to_i
      bill_type = attrs["type"]
      number = attrs["number"].to_i
      b = Bill.find_by_session_and_bill_type_and_number(session, bill_type, number)
      if b.nil? || @meeting.nil?
        #nop?
      else
        CommitteeMeetingsBill.find_or_create_by_committee_meeting_id_and_bill_id(@meeting.id, b.id)
      end
    when "subject"
      @ready_for_text = true
    end
  end
  
  def tag_end(name)
    if name == "meeting" && !(@meeting.nil?)
      @meeting.save
      @meeting = nil
    elsif name == "subject"
      @ready_for_text = false
    end
  end

  def text(text)
    if !(@meeting.nil?) && @ready_for_text
      @meeting.subject = text
    end
  end
end

source = File.open(path)
listener = CommitteeScheduleListener.new
REXML::Document.parse_stream(source, listener)
