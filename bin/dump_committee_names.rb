#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../config/environment'
require 'rexml/document'

people = Settings.govtrack_data_path + "/#{Settings.default_congress}/repstats/people.xml"
bills = Settings.govtrack_data_path + "/#{Settings.default_congress}/bills.index.xml"

class CommitteeNames

end

listener = CommitteeNamesListener.new
REXML::
