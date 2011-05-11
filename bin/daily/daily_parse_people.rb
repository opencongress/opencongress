#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../../config/environment'
end

require  File.dirname(__FILE__) + '/../../app/models/action.rb'
require  File.dirname(__FILE__) + '/../../app/models/person.rb'

require 'rexml/document'
require 'ostruct'
require 'date'
require 'yaml'

class PeopleListener 
  attr_reader :count

  def initialize
    @count = 0
    @people = Person.find(:all).group_by(&:id)
    @committees = {}
    @current_roles = []
    @current_committees = []
  end

  def tag_start(name, attrs)
    case name
    when "people"
      #nop
    when "person"
      make_person(attrs)
    when "role"
      make_role(attrs)
    when "current-committee-assignment"
      make_committee_assignment(attrs)
    end
  end

  def tag_end(name)
    case name
    when "person"
      @person.roles = @current_roles
      @person.committee_people = @current_committees

      @person.save 
      
      @person.create_person_stats if @person.person_stats.nil? 
      
      @person = nil
      @current_roles = []
      @current_committees = []
    end
  end

  def make_person(attrs)
    id = attrs['id'].to_i
    arr = @people[id]
    @person = arr[0] unless arr.nil?
    @person ||= Person.new
    @attributes = @person.attributes
    @person.id = id 
    @person.lastname = attrs['lastname']
    @person.middlename = attrs['middlename']
    
    # govtrack has Kent Conrad as Gaylord Conrad (though THOMAS has Kent Conrad, 
    # and he uses Kent, actually)
    # fix name here at the request of Senator Conrad
    if /Gaylord Conrad/.match(attrs['name'])
      @person.name = attrs['name'].gsub(/Gaylord/,"Kent")
      @person.firstname = 'Kent'
    elsif @person.id == 412223
      @person.name = 'Sen. Kirsten Gillibrand [D, NY]'
      @person.title = 'Sen.'
    else
      @person.name = attrs['name']
      @person.firstname = attrs['firstname']
    end
    @person.unaccented_name = replace_accents("#{@person.firstname} #{@person.lastname}")

    @person.nickname = attrs['nickname']
    date = attrs['birthday']
    @person.birthday = Date.strptime(date, "%Y-%m-%d") if ((date) && (date != '0000-00-00'))
    @person.gender = attrs['gender']
    @person.religion = attrs['religion']
    @person.url = attrs['url']
    @person.party = attrs['party']
    @person.osid = attrs['osid']
    @person.bioguideid = attrs['bioguideid']
    @person.youtube_id = attrs['youtubeid']
    @person.metavid_id = attrs['metavidid']
    @person.title = attrs['title']
    @person.district = attrs['district']
    @person.state = attrs['state']
    @person.email = attrs['email']
  end

  def make_role(as)
    startdate = as['startdate']
    startdate = Date.strptime(startdate, "%Y-%m-%d") if startdate && (startdate != '0000-00-00')
    enddate = as['enddate']
    enddate = Date.strptime(enddate, "%Y-%m-%d") if enddate && (enddate != '0000-00-00')
    
    role = Role.find_or_initialize_by_person_id_and_startdate_and_enddate(@person.id, startdate, enddate)
    role.role_type = as['type']
    role.party = as['party']
    role.state = as['state']
    role.district = as['district']
    role.url = as['url']
    role.address = as['address']
    role.phone = as['phone']
    role.email = as['email']
    role.save
    
    @current_roles << role
  end

  def make_committee_assignment(as)
    name = as['committee'] || ''
    subcommittee_name = as['subcommittee'] || ''
    comms = Committee.find_by_query(name, subcommittee_name)
    if !comms.empty? && comms.size == 1
      comm = comms.first
      cp = CommitteePerson.find_or_initialize_by_person_id_and_committee_id(@person.id, comm.id)
      if !as['role'].nil? && !as['role'].blank?
        cp.role = as['role']
      end
      # temp for now until Josh changes data definition
      cp.session = Settings.default_congress
      cp.save
      
      @current_committees << cp
    end
  end

  def text(text)
    #nop
  end

  def xmldecl(*args)
    #nop
  end
  
  def replace_accents(accented)
    accented.gsub!(/[áàâäå]+/, 'a')
    accented.gsub!(/[ÁÀÂÄÅ]+/, 'A')
    accented.gsub!(/[éèêë]+/, 'e')
    accented.gsub!(/[ÉÈÊË]+/, 'E')
    accented
  end

  def method_missing(*args)
    puts args.inspect
    raise "ack"
  end
end

puts "people parsed"

Person.transaction {
  source = File.open(Settings.govtrack_data_path + "/#{Settings.default_congress}/../people.xml")
  
  listener = PeopleListener.new
  REXML::Document.parse_stream(source, listener)
}

