#!/usr/bin/env ruby

# Purpose: Sync changes to OpenCongress users (new users, updated users, deleted users) with the CiviCRM mailing list
# for OpenCongress: names, locations, and e-mail addresses are kept in sync. This script should be run nightly.

# We access OC user audit data via ActiveRecord, and CiviCRM via a REST call.
# See http://wiki.civicrm.org/confluence/display/CRMDOC/REST+interface
# for full CiviCRM rest documentation.

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../config/environment'
end

require 'uri'
require 'rexml/document'
require 'ostruct'
require 'hpricot'
require 'open-uri'
require 'iconv'
require 'fileutils'
require 'cgi'

#LAST_SYNC_FN = "/data/opencongress/civicrm-opencongress-last-sync-date.txt"
LAST_SYNC_FN = "civicrm-opencongress-last-sync-date.txt"


# When did we last sync? Check in.
last_sync_at = Time.at(0)
if File.exists?(LAST_SYNC_FN)
  last_sync_at = File.mtime(LAST_SYNC_FN)
end

# TODO: Use SSL for this.
base_url = 'http://crm.ppolitics.org/sites/all/modules/civicrm/extern/rest.php?q=civicrm'

# This is the key in civicrm.settings.php
key = API_KEYS['civicrm_system_key']

# And this is the key for our "extern" user (in MySQL civicrm_contact.api_key)
api_key = API_KEYS['civicrm_user_key']

auth = "&key=#{API_KEYS['civicrm_system_key']}&api_key=#{API_KEYS['civicrm_user_key']}"

def get(query)
  return Hpricot(open(base_url + query + auth))
end

UserAudit.all.each do |audit|
  doc = get("/contact/search&email=#{CGI.escape(a.email_was? ? a[:email_was] : a.email)}")

  contact_id = (doc/"contact_id").first
  
  # When someone needs to be created
  create_uri = "&first_name=#{CGI.escape(a.full_name)}&email=#{CGI.escape(a.email)}&contact_type=Individual"

  case a.action
  when 'subscribe', 'unsubscribe':
    opt_out = "&is_opt_out=#{a.action == "subscribe" ? 0 : 1}"
    # If someone is found:
    if contact_id = (doc/"contact_id").first
      followup_uri = "/contact/add&contact_id=#{contact_id}" + opt_out
    else
      # Create a new contact
      followup_uri = create_uri + opt_out
    end
  when 'update':
    # If contact found:
    if contact_id = (doc/"contact_id").first
      followup_uri = "/contact/add&contact_id=#{contact.contact_id}&first_name=#{u.full_name}&email=#{a.email}"
    else
      # Create a new contact
      followup_uri = create_uri
    end
  end

  puts followup_uri
  # result = get(followup_uri)
end

# We're done! Update the last sync file.
FileUtils.touch(LAST_SYNC_FN)
