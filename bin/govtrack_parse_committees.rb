#!/usr/bin/env ruby

#rails include
require File.dirname(__FILE__) + '/../config/environment'
require 'rexml/document'
require 'ostruct'

#You probably don't have this file in this spot.
FILE_NAME = "/data/govtrack/109/repstats/people.xml"

SUBCOMMITTEE_NAMES = {
"Capital Markets, Insurance and Government Sponsored Enterprises" => "Capital Markets, Insurance, and Government Sponsored Enterprises",
"General Farm Commodities and Risk Management" => "Farm Commodities and Risk Management",
"Conservation, Credit, Rural Development, and Research" => "Conservation, Credit, Rural Development and Research",
"Projection Forces" => " Projection Forces",
"Commerce, Trade, and Consumer Protection" => "Commerce, Trade and Consumer Protection",
"Management, Integration, and Oversight" => "Management, Integration and Oversight",
"The Western Hemisphere" => "Western Hemisphere",
"The Constitution" => "Constitution",
"Public Lands and Forests " => "Public Lands and Forests",
"Oversight of Government Management, the Federal Workforce, and the District of Columbia" => "Oversight of Government Management, the Federal Workforce and the District of Columbia",
"Middle East and Central Asia" => "The Middle East and Central Asia",
}

COMMITTEE_NAMES = {
"Senate the Judiciary" => "Senate Judiciary",
"Senate the Budget" => "Senate Budget",
"House the Judiciary" => "House Judiciary",
"House the Budget" => "House Budget",
"Joint the Library" => "Joint Library"
}

NEW_COMMITTEES = [
["House Administration", nil],
["House Appropriations", "Agriculture, Rural Development, Food and Drug Administration, and Related Agencies"],
["House Appropriations", "Defense"],
["House Appropriations", "Energy and Water Development, and Related Agencies"],
["House Appropriations", "Foreign Operations, Export Financing, and Related Programs"],
["House Appropriations", "Homeland Security"],
["House Appropriations", "Interior, Environment, and Related Agencies"],
["House Appropriations", "Labor, Health and Human Services, Education, and Related Agencies"],
["House Appropriations", "Military Quality of Life and Veterans Affairs, and Related Agencies"],
["House Appropriations", "Science, The Departments of State, Justice, and Commerce, and Related Agencies"],
["House Appropriations", "Transportation, Treasury, HUD, The Judiciary, District of Columbia, and Independent Agencies"],
["House Budget", nil],
["House Energy and Commerce", "Oversight and Investigations"],
["House Financial Services", "Domestic and International Monetary Policy, Trade and Technology"],
["House Financial Services", "Domestic and International Monetary Policy, Trade, and Technology"],
["House Financial Services", "Oversight and Investigations"],
["House Government Reform", "Criminal Justice, Drug Policy and Human Resources"],
["House Government Reform", "Energy and Resources"],
["House Government Reform", "Government Management, Finance, and Accountability"],
["House Government Reform", "National Security, Emerging Threats and International Relations"],
["House Government Reform", "Regulatory Affairs"],
["House Homeland Security", "Investigations"],
["House Homeland Security", "Management, Integration and Oversight"],
["House Homeland Security", "Management, Integration, and Oversight"],
["House House Administration", nil],
["House Intelligence (Permanent Select)", nil],
["House International Relations", "Oversight and Investigations"],
["House Judiciary", "Commercial and Administrative Law"],
["House Judiciary", "Courts, the Internet, and Intellectual Property"],
["House Judiciary", "Crime, Terrorism, and Homeland Security"],
["House Judiciary", "Immigration, Border Security, and Claims"],
["House Judiciary", nil],
["House Permanent Select Intelligence", "Intelligence Policy"],
["House Permanent Select Intelligence", "Oversight"],
["House Permanent Select Intelligence", "Technical and Tactical Intelligence"],
["House Permanent Select Intelligence", "Terrorism, Human Intelligence, Analysis and Counterintelligence"],
["House Permanent Select Intelligence", nil],
["House Rules", "Legislative and Budget Process"],
["House Rules", "Rules and the Organization of the House"],
["House Small Business", "Regulatory Reform and Oversight"],
["House Small Business", "Rural Enterprises, Agriculture, and Technology"],
["House Small Business", "Tax, Finance, and Exports"],
["House Small Business", "Workforce, Empowerment, and Government Programs"],
["House Ways and Means", "Oversight"],
["House Ways and Means", "Select Revenue Measures"],
["Joint Economic Committee", nil],
["Joint Library", nil],
["Joint Library", nil],
["Joint Printing", nil],
["Joint Taxation", nil],
["Senate Aging (Special)", nil],
["Senate Agriculture, Nutrition, and Forestry", "Marketing, Inspection, and Product Promotion"],
["Senate Agriculture, Nutrition, and Forestry", "Production and Price Competitiveness"],
["Senate Agriculture, Nutrition, and Forestry", "Research, Nutrition, and General Legislation"],
["Senate Appropriations", "Commerce, Justice, Science and Related Agencies"],
["Senate Appropriations", "Commerce, Justice, and Science and Related Agencies"],
["Senate Appropriations", "Labor, Health and Human Services, Education, and Related Agencies"],
["Senate Appropriations", "Legislative Branch"],
["Senate Armed Services", "Airland"],
["Senate Armed Services", "Emerging Threats and Capabilities"],
["Senate Armed Services", "Personnel"],
["Senate Armed Services", "Readiness and Management Support"],
["Senate Armed Services", "SeaPower"],
["Senate Armed Services", "Strategic Forces"],
["Senate Banking, Housing, and Urban Affairs", "Economic Policy"],
["Senate Banking, Housing, and Urban Affairs", "Financial Institutions"],
["Senate Banking, Housing, and Urban Affairs", "International Trade and Finance"],
["Senate Banking, Housing, and Urban Affairs", "Securities and Investment"],
["Senate Commerce, Science, and Transportation", "Disaster Prevention and Prediction"],
["Senate Commerce, Science, and Transportation", "Fisheries and Coast Guard"],
["Senate Commerce, Science, and Transportation", "Global Climate Change and Impacts"],
["Senate Commerce, Science, and Transportation", "National Ocean Policy Study"], ["Senate Commerce, Science, and Transportation", "Aviation"],
["Senate Commerce, Science, and Transportation", "Science and Space"],
["Senate Commerce, Science, and Transportation", "Surface Transportation and Merchant Marine"],
["Senate Commerce, Science, and Transportation", "Technology, Innovation, and Competitiveness"],
["Senate Energy and Natural Resources", "Energy "],
["Senate Environment and Public Works", "Fisheries, Wildlife, and Water"],
["Senate Environment and Public Works", "Superfund and Waste Management"],
["Senate Environment and Public Works", "Transportation and Infrastructure"],
["Senate Finance", "Health Care"],
["Senate Finance", "International Trade"],
["Senate Finance", "Long-term Growth and Debt Reduction"],
["Senate Finance", "Social Security and Family Policy"],
["Senate Finance", "Taxation and IRS Oversight"],
["Senate Foreign Relations", "African Affairs"],
["Senate Foreign Relations", "East Asian and Pacific Affairs"],
["Senate Foreign Relations", "European Affairs"],
["Senate Foreign Relations", "International Economic Policy, Export and Trade Promotion"],
["Senate Foreign Relations", "International Operations and Terrorism"],
["Senate Foreign Relations", "Near Eastern and South Asian Affairs"],
["Senate Foreign Relations", "Western Hemisphere, Peace Corps and Narcotics Affairs"],
["Senate Health, Education, Labor, and Pensions", "Employment and Workplace Safety"],
["Senate Health, Education, Labor, and Pensions", "Retirement Security and Aging"],
["Senate Homeland Security and Governmental Affairs", "Permanent Subcommittee on Investigations"],
["Senate Indian Affairs", nil],
["Senate Intelligence (Select)", nil],
["Senate Judiciary", "Antitrust, Competition Policy and Consumer Rights"],
["Senate Judiciary", "Corrections and Rehabilitation"],
["Senate Judiciary", "Crime and Drugs"],
["Senate Judiciary", "Immigration, Border Security and Citizenship"],
["Senate Judiciary", "Intellectual Property"],
["Senate Judiciary", nil],
["Senate Rules and Administration", nil],
["Senate Select Ethics", nil],
["Senate Small Business and Entrepreneurship", nil],
["Senate Special Aging", nil],
["Senate Veterans' Affairs", nil],
["United States Senate Caucus on International Narcotics Control", nil],
]

$lost = {}
$new = {}

class PeopleListener
  def initialize
    @people = {} #indexed by ID
    @comms = Committee.find_all.group_by {|c| [c.name, c.subcommittee_name]}
  end

  def xmldecl(*args)
    #nop
  end

  def tag_start(name, attrs)
    case name
    when "people"
      #nop
    when "person"
      @id = attrs["id"].to_i
    when "current-committee-assignment"
      @people[@id] ||= Person.find @id
      name, sub = attrs["committee"].sub(/\s+committee on\s+/i, " "), attrs["subcommittee"]
      name.gsub!(/\s+/, " ") unless name.nil?
      sub.gsub!(/\s+/, " ") unless sub.nil?
      if COMMITTEE_NAMES.include? name
        name = COMMITTEE_NAMES[name] 
      end
      if SUBCOMMITTEE_NAMES.include? sub
        sub = SUBCOMMITTEE_NAMES[sub] 
      end
      double = [name,sub]

      if NEW_COMMITTEES.include?(double) && Committee.find_by_name_and_subcommittee_name(name, sub).nil?
        $new[double] ||= :new
        c = Committee.new
        c.name = name
        c.subcommittee_name = name
        c.save
        @comms[double] ||= [c]
      elsif @comms[[name, sub]].nil?
        $lost[double] ||= 0
        $lost[double] += 1
      end
	
	    if @comms[double]
	      raise "oh noes!" if @comms[double].length > 1

        comm = @comms[double][0]
        cp = CommitteePerson.find_by_committee_id_and_person_id(comm.id,@id)
        if cp.nil?
          cp = CommitteePerson.new
          cp.committee = comm
          cp.person = @people[@id]
        end
        if attrs.has_key? "role"
          cp.role = attrs["role"]
        end
        cp.save
      end
    end
  end

  def tag_end(name)
    case name
    when "people"
      puts "Couldn't assign these committees: #{$lost.inspect}"
    when "person"
      #nop
    end
  end

  def xmldecl(*args)
    #nop
  end

  def text(text)
    #nop
  end

end

source = File.open(FILE_NAME, 'r')
listener = PeopleListener.new
REXML::Document.parse_stream(source, listener)
