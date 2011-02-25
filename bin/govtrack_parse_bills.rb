#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../config/environment'

#Just parses the summary, to get things into the right table.

require 'rexml/document'
require 'ostruct'
require 'date'
require 'yaml'

class BillsListener 
  def initialize
    @bills = []
  end

  def tag_start(name, attrs)
    case name
    when "bills"
      #nop
    when "bill"
      parse_bill(attrs)
    when "introduced"
      os = OpenStruct.new(attrs)
      @bill["introduced_struct"] = os
    else
      os = OpenStruct.new(attrs)
      @bill[name] = os
    end
  end

  def tag_end(name)
    case name
      when "bill":
        add_bill
      when "bills":
        make_bills
        puts "all done!"
    end
  end

  def add_bill
    @bills.push OpenStruct.new(@bill)
    if @bills.size == 100
      make_bills
      @bills = []
    end
  end

  def make_bills
    Bill.transaction do 
      @bills.each do |os|
        b = Bill.new
        b.number = os.number.to_i
        b.session = os.session.to_i
        b.bill_type = os.bill_type
        raise "No bill type" if os.bill_type.nil?
        b.introduced = os.introduced
        raise "No introduced" if (os.introduced.nil? || os.introduced == '')
        raise os.introduced.to_s if b.introduced.nil?
        b.sponsor_id = os.sponsor.to_i
        raise "No sponsor" if os.sponsor.nil?
        b.last_vote_date = os.last_vote_date.to_i unless os.last_vote_date == ''
        b.last_vote_where = os.last_vote_where unless os.last_vote_where == ''
        b.last_vote_roll = os.last_vote_roll unless os.last_vote_roll == ''
        b.last_speech = os.last_speech.to_i unless os.last_speech == ''
        b.pl = os.pl unless os.pl == ''
        b.rolls = os.rolls unless os.rolls == ''
        unless os.topresident.nil?
          b.topresident_date = os.topresident.date
          b.topresident_datetime = DateTime.parse(os.topresident.datetime)
        end
        b.save 
      end
    end
  end

  def parse_bill(attributes)
    @bill = attributes
    @bill['bill_type'] = @bill['type']
  end

  def text(text)
    #nop
  end

  def xmldecl(*args)
    #nop
  end

  def method_missing(*args)
    puts args.inspect
    raise "ack"
  end
end

source = File.open(Settings.govtrack_data_path + "/#{Settings.default_congress}/bills.index.xml")
listener = BillsListener.new
REXML::Document.parse_stream(source, listener)
