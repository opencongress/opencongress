#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../config/environment'

require 'htree'
require 'uformatparser'

class PeopleParser
  include MicroformatParser

  class ParsedPerson
    include MicroformatParser

    rule_1 :id, "person", "@id"
    rule_1 :lastname, "person", "@lastname"
    rule_1 :middlename, "person", "@middlename"
    rule_1 :firstname, "person", "@firstname"
    rule_1 :nickname, "person", "@nickname"
    rule_1 :birthday, "person", "@birthday"
    rule_1 :gender, "person", "@gender"
    rule_1 :religion, "person", "@religion"
    rule_1 :url, "person", "@url"
    rule_1 :party, "person", "@party"
    rule_1 :osid, "person", "@osid"
    rule_1 :bioguideid, "person", "@bioguideid"
    rule_1 :title, "person", "@title"
    rule_1 :district, "person", "@district"
    rule_1 :state, "person", "@state"
    rule_1 :name, "person", "@name"
    rule_1 :email, "person", "@email"

    class ParsedRole
      include MicroformatParser

      rule_1 :type, "role", "@type"
      rule_1 :startdate, "role", "@startdate"
      rule_1 :enddate, "role", "@enddate"
      rule_1 :party, "role", "@party"
      rule_1 :state, "role", "@state"
      rule_1 :district, "role", "@disctrict"
      rule_1 :url, "role", "@url"
      rule_1 :address, "role", "@address"
      rule_1 :phone, "role", "@phone"
      rule_1 :email, "role", "@email"
    end

    rule :roles, "role", ParsedRole
  end

  rule :people, "person", ParsedPerson 
end

# read in the file
puts "reading file"
peopleFile = File.open(Settings.govtrack_data_path + "/#{Settings.default_congress}/repstats/people.xml", "r")
puts "to_rexml"
xml = HTree(peopleFile).to_rexml

peopleFile.close

puts "people parser"
people = PeopleParser.parse(xml.document)
if people.people
  for parsedPerson in people.people
    begin
      tempPerson = Person.find(parsedPerson.id)
    rescue
      tempPerson = Person.new
      tempPerson.id = parsedPerson.id
    end

    tempPerson.lastname = parsedPerson.lastname
    tempPerson.middlename = parsedPerson.middlename
    tempPerson.firstname = parsedPerson.firstname
    tempPerson.nickname = parsedPerson.nickname
    tempPerson.birthday = Date.strptime(parsedPerson.birthday, "%Y-%m-%d") if ((parsedPerson.birthday) && (parsedPerson.birthday != '0000-00-00'))
    tempPerson.gender = parsedPerson.gender
    tempPerson.religion = parsedPerson.religion
    tempPerson.url = parsedPerson.url
    tempPerson.party = parsedPerson.party
    tempPerson.osid = parsedPerson.osid
    tempPerson.bioguideid = parsedPerson.bioguideid
    tempPerson.osid = parsedPerson.osid
    tempPerson.title = parsedPerson.title
    tempPerson.district = parsedPerson.district
    tempPerson.state = parsedPerson.state
    tempPerson.name = parsedPerson.name
    tempPerson.email = parsedPerson.email

    unless tempPerson.save
      puts "Could not save record"
    end  

    # now save the person's roles

    if parsedPerson.roles
      for parsedRole in parsedPerson.roles
        # see if this role exists
        tempStartDate = Date.strptime(parsedRole.startdate, "%Y-%m-%d")
        begin
          tempRole = Role.find(:first,
                      :conditions => ["people_id=? AND startdate=?", parsedPerson.id, tempStartDate])
          unless tempRole
            tempRole = Role.new
            tempRole.person = tempPerson
          end
        rescue
          tempRole = Role.new
          tempRole.person = tempPerson
        end

        tempRole.role_type = parsedRole.type
        tempRole.startdate = tempStartDate
        tempRole.enddate = Date.strptime(parsedRole.enddate, "%Y-%m-%d")
        tempRole.party = parsedRole.party
        tempRole.state = parsedRole.state
        tempRole.district = parsedRole.district
        tempRole.url = parsedRole.url
        tempRole.address = parsedRole.address
        tempRole.phone = parsedRole.phone
        tempRole.email = parsedRole.email

        unless tempRole.save
          puts "can't save role!"
        end
        puts tempRole.inspect
        
        tempRole = nil
        break
      end
    end
    
    parsedPerson.roles = nil
  end
  
  tempPerson = nil
  parsedPerson = nil
end

