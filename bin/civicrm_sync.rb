#!/usr/bin/env ruby

# Purpose: Sync changes to OpenCongress users (new users, updated users, deleted users) with the CiviCRM mailing list
# for OpenCongress: names, locations, and e-mail addresses are kept in sync. This script should be run nightly.

# We access OC user audit data via ActiveRecord, and CiviCRM via a REST call.
# See http://wiki.civicrm.org/confluence/display/CRMDOC/REST+interface
# for full CiviCRM rest documentation.

# This script depends on the CiviCRM database NOT having duplicate e-mail addresses.
# If a query returns duplicate results, we'll update only the first contact found.

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

LAST_SYNC_FN = "/data/opencongress/civicrm-opencongress-last-sync-date.txt"
#LAST_SYNC_FN = "civicrm-opencongress-last-sync-date.txt"
AUTH_PART = "&key=#{API_KEYS['civicrm_system_key']}&api_key=#{API_KEYS['civicrm_user_key']}"

# The group_id of OpenCongress in CiviCRM
OC_CIVICRM_GROUP_ID = "4"

# When did we last sync? Check in.
last_sync_at = Time.at(0)
if File.exists?(LAST_SYNC_FN)
  last_sync_at = File.mtime(LAST_SYNC_FN)
end

def es(str)
  str && str.instance_of?(String) ? CGI.escape(str) : str
end

def first_inner(doc, elem)
  (doc/elem).first && (doc/elem).first.inner_html
end


def get(query)
  # TODO: Use SSL for this.
  Rails.logger.debug "Opening " + 'http://crm.ppolitics.org/sites/all/modules/civicrm/extern/rest.php?q=civicrm' + query + AUTH_PART
  doc = Hpricot(open('http://crm.ppolitics.org/sites/all/modules/civicrm/extern/rest.php?q=civicrm' + query + AUTH_PART))

  if !(doc/"is_error").empty? && (doc/"is_error").first.inner_html == "1"
    puts "Error: #{first_inner(doc, "error_message")}"
    exit 0
  end

  return doc
end

def add_to_group(id)
  get("/group_contact/add&contact_id=#{id}&group_id=#{OC_CIVICRM_GROUP_ID}")
end

def add_contact(ops = {})
  uri = ""
  ops[:contact_type] = "Individual"
  ops.each { |l, r| uri = uri + "&#{l}=#{es(r)}"}

  return get("/contact/add" + ops)
end

# The main loop.
UserAudit.all(:conditions => ["created_at > ?", last_sync_at]).each do |a|
  doc = get("/contact/search&email=#{es(a.email_was? ? a[:email_was] : a.email)}")

  contact_id = first_inner(doc, "contact_id")

  case a.action
  when 'subscribe', 'unsubscribe':
    # If someone is found:
    if contact_id = first_inner(doc, "contact_id")
      Rails.logger.debug "Updating opt out for contact id ##{contact_id} (#{a.email})"
      doc = add_contact :contact_id => contact_id, :is_opt_out => (a.action == "subscribe" ? 0 : 1)
    else
      # Create a new contact
      puts "Going to create a new contact for #{a.full_name}"
      c = add_contact :first_name => a.full_name, :email => a.email, :is_opt_out => (a.action == "subscribe" ? 0 : 1)
      if new_id = first_inner(c, "contact_id")
        add_to_group new_id
      else
        Rails.logger.error "Error: No contact ID for new contact"
      end
    end
  when 'update':
    # If contact found:
    if contact_id = first_inner(doc, "contact_id")
      Rails.logger.debug "Updating CiviCRM contact ##{contact_id}"
      add_contact :contact_id => contact_id, :first_name => a.full_name, :email => a.email
    else
      # Create a new contact
      Rails.logger.debug "Creating a new contact"
      c = add_contact :first_name => a.full_name, :email => a.email
      if new_id = first_inner(c, "contact_id")
        add_to_group new_id
      end
    end
  end

end

# We're done! Update the last sync date.
FileUtils.touch(LAST_SYNC_FN)
