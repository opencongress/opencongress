#!/usr/bin/env ruby

#### LOAD RAILS ENVIRONMENT
APP_PATH = File.expand_path('../../config/application',  __FILE__)
require File.expand_path('../../config/boot',  __FILE__)
ENV["RAILS_ENV"] ||= "development"
require APP_PATH
Rails.application.require_environment!
###########################

people = Person.all_sitting
people.each do |p|

  if p.formageddon_contact_steps.empty?
    puts "Skipping #{p.name}.  Not configured."
  else
    thread = Formageddon::FormageddonThread.new
    thread.formageddon_recipient = p
    thread.sender_email = "david@opencongress.org"
    thread.sender_title = "Mr."
    thread.sender_first_name = "David"
    thread.sender_last_name = "Moore"
    thread.sender_address1 = "123 Someplace Ln."
    thread.sender_city = "Some City"
    thread.sender_state = p.state

    if p.title == 'Rep.'
      zd = ZipcodeDistrict.where(["state=? and district=? and zip5 is not null and zip4 is not null", p.state, p.district]).order('zip4').first
    else
      zd = ZipcodeDistrict.where(["state=? and zip5 is not null and zip4 is not null", p.state]).order('zip4').first
    end

    if zd
      thread.sender_zip5 = zd.zip5
      thread.sender_zip4 = zd.zip4

      y = YahooGeocoder.new("#{zd.zip5}-#{zd.zip4}")
      
      thread.sender_city = y.city
    end
    
    thread.save
        
    message = "
OpenCongress.org, a free & open-source public resource website for transparency in the U.S. Congress, urges all members of Congress to support the Principles of Open Government Data :: 

http://www.opengovdata.org/

First drafted by volunteers in 2007, these principles help ensure that legislative data is open to the public and that government is as accountable as possible in our representative democracy. We're currently soliciting members of the U.S. Congress to become signatories of these community-generated principles in a forthcoming blog post on our flagship website, OpenCongress.org. Please have your office reply to this email with your current position on endorsing the Principles below :: 
Open Government Data Definition: The 8 Principles of Open Government Data

Government data shall be considered open if the data are made public in a way that complies with the principles below:
1. Data Must Be Complete
All public data are made available. Data are electronically stored information or recordings, including but not limited to documents, databases, transcripts, and audio/visual recordings. Public data are data that are not subject to valid privacy, security or privilege limitations, as governed by other statutes.
2. Data Must Be Primary
Data are published as collected at the source, with the finest possible level of granularity, not in aggregate or modified forms.
3. Data Must Be Timely
Data are made available as quickly as necessary to preserve the value of the data.
4. Data Must Be Accessible
Data are available to the widest range of users for the widest range of purposes.
5. Data Must Be Machine processable
Data are reasonably structured to allow automated processing of it.
6. Access Must Be Non-Discriminatory
Data are available to anyone, with no requirement of registration.
7. Data Formats Must Be Non-Proprietary
Data are available in a format over which no entity has exclusive control.
8. Data Must Be License-free
Data are not subject to any copyright, patent, trademark or trade secret regulation. Reasonable privacy, security and privilege restrictions may be allowed as governed by other statutes.
Finally, compliance must be reviewable.
A contact person must be designated to respond to people trying to use the data.
A contact person must be designated to respond to complaints about violations of the principles.
An administrative or judicial court must have the jurisdiction to review whether the agency has applied these principles appropriately.

Sincerely, 

David Moore
Program Manager, OpenCongress.org 

david@opencongress.org

(917) 753-3462

www.opencongress.org
"

    thread.formageddon_letters.create(:subject => "Support the Principles of Open Government Data", :message => message, :issue_area => 'Other', :direction => 'TO_RECIPIENT', :status => 'START')
    
    thread.formageddon_letters.first.send_letter
  end
end
