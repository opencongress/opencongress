#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../config/environment'
require 'rexml/document'

people = GOVTRACK_DATA_PATH + "/repstats/people.xml"
bills = GOVTRACK_DATA_PATH + "/bills.index.xml"

class CommitteeNames

end

listener = CommitteeNamesListener.new
REXML::
