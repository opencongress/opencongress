#!/usr/bin/env ruby

#### LOAD RAILS ENVIRONMENT
APP_PATH = File.expand_path('../../config/application',  __FILE__)
require File.expand_path('../../config/boot',  __FILE__)
ENV["RAILS_ENV"] ||= "development"
require APP_PATH
Rails.application.require_environment!
###########################


Formageddon::IncomingEmailFetcher.fetch do |letter|
  cclft = ContactCongressLettersFormageddonThread.where(["formageddon_thread_id=?", letter.formageddon_thread.id]).first
  
  if cclft
    puts "Sending an email notification to: #{cclft.contact_congress_letter.user.email}"
    ContactCongressMailer.reply_received_email(cclft.contact_congress_letter, letter.formageddon_thread).deliver
  end
end