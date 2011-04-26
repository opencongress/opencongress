#!/usr/bin/env ruby

# Purpose: Sync changes to OpenCongress users (new users, updated users, deleted users) with the CiviCRM mailing list
# for OpenCongress: names, locations, and e-mail addresses are kept in sync. This script should be run nightly.

# We access OC user audit data via ActiveRecord, and CiviCRM via a REST call.
# See http://wiki.civicrm.org/confluence/display/CRMDOC/REST+interface
# for full CiviCRM rest documentation.

# This script depends on the CiviCRM database NOT having duplicate e-mail addresses.
# If a query returns duplicate results, we'll update only the first contact found.

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../../config/environment'
end

require 'uri'
require 'rexml/document'
require 'ostruct'
require 'hpricot'
require 'open-uri'
require 'iconv'
require 'fileutils'
require 'cgi'

AUTH_PART = "&key=#{ApiKeys.civicrm_system_key}&api_key=#{ApiKeys.civicrm_user_key}"

# The group_id of OpenCongress in CiviCRM
OC_CIVICRM_GROUP_ID = "4"

def es(str)
  str && str.instance_of?(String) ? CGI.escape(str) : str
end

def first_inner(doc, elem)
  (doc/elem).first && (doc/elem).first.inner_html
end

def get(query)
  # TODO: Use SSL for this.
  # puts "Opening " + query + AUTH_PART
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

  return get("/contact/add" + uri)
end

# The main loop.
UserAudit.all(:conditions => ["processed = false"], :order => "created_at").each do |a|
  doc = get("/contact/search&email=#{es(a.email_was? ? a[:email_was] : a.email)}")

  # If someone is found:
  if contact_id = first_inner(doc, "contact_id")
    puts "- Updating contact id ##{contact_id} (#{a.email})"
    add_contact(
      :contact_id => contact_id,
      :first_name => a.full_name,
      "email[1][email]" => a.email,
      "email[1][location_type_id]" => 1,
      "address[1][location_type_id]" => 1,
      "address[1][postal_code]" => a.zipcode,
      :custom_1 => a.district,
      :external_identifier => a.user_id,
      :is_opt_out => (a.mailing ? 1 : 0)
    )
  elsif a.mailing
    # If we're adding this person to the mailing list,
    # create a new contact
    puts "- Creating a new contact for #{a.full_name}"
    c = add_contact(
      :first_name => a.full_name,
      "email[1][email]" => a.email,
      "email[1][location_type_id]" => 1,
      "address[1][location_type_id]" => 1,
      "address[1][postal_code]" => a.zipcode,
      :external_identifier => a.user_id,
      :custom_1 => a.district
    )
    if new_id = first_inner(c, "contact_id")
      add_to_group new_id
    else
      puts "Error: No contact ID for new contact"
    end
  else
    puts "- Not adding civicrm user for #{a.email}: opt-out."
  end

  a.processed = true
  a.save
end
