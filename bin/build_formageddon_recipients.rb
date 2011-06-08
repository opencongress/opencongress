#!/usr/bin/env ruby

#### LOAD RAILS ENVIRONMENT
APP_PATH = File.expand_path('../../config/application',  __FILE__)
require File.expand_path('../../config/boot',  __FILE__)
ENV["RAILS_ENV"] ||= "development"
require APP_PATH
Rails.application.require_environment!
###########################

require 'formageddon_helper'



def is_contact_form(page, form)
  form.fields.each do |f|
    puts "Trying field: #{f.name} / #{label_text_for(page, f.node)}"
    if f.name =~ /zip/i or label_text_for(page, f.node) =~ /zip/i
      return true
    end
  end
  
  return false
end

def average_name_length(form)
  sum = 0
  form.fields.each do |f|
    sum += f.name.length
  end
  sum /= form.fields.size
  
  puts "Average name length: #{sum}"
  sum
end

def predict_selection(page, input)
  case input.name
  when 'textarea'
    return :message
  when 'select'
    case input.attributes["name"].value + label_text_for(page, input)
    when /salutation/i, /prefix/i
      return :title
    when /state/i
      return :state
    when /topic/i, /subject/i
      return :issue_area
    end
  when 'input'
    unless input.attributes['type'].nil?
      case input.attributes["type"].value
      when 'image', 'submit'
        return :submit_button
      when 'text'
        case input.attributes['name'].value + label_text_for(page, input)
        when /prefix/i
          return :title
        when /subject/i
          return :subject
        when /captcha/i
          return :captcha_solution
        when /email/i
          return :email
        when /phone/i
          return :phone
        when /zip4/i, /zipplus4/i, /plusfour/i, /zipfour/i
          return :zip4
        when /zipcode/i, /zip/i
          return :zip5
        when /city/i
          return :city
        when /state/i
          return :state
        when /address2/i, /address 2/i, /address_2/i, /street2/i
          return :address2
        when /address/i, /address 1/i, /street/i
          return :address1
        when /firstname/i, /first name/i, /first_name/i, /fname/i, /first/i
          return :first_name
        when /lastname/i, /last name/i, /last_name/i, /lname/i, /lname/i, /last/i
          return :last_name
        end
      end
    end
  end
  
  return :leave_blank
end

def label_for(field)
  case field.to_s
  when :title, 'title', 'sender_title'
    'Title/Salutation'
  when :first_name, 'first_name', 'sender_first_name'
    'First Name'
  when :last_name, 'last_name', 'sender_last_name'
    'Last Name'
  when :email, 'email', 'sender_email'
    'Email address'
  when :address1, 'address1', 'sender_address1'
    'Address'
  when :address2, 'address2', 'sender_address2'
    'Address (cont.)'
  when :city, 'city', 'sender_city'
    'City'
  when :state, 'state', 'sender_state'
    'State'
  when :zip5, 'zip5', 'sender_zip5'
    'Zip Code'
  when :zip4, 'zip4', 'sender_zip4'
    'Zip+4'
  when :phone, 'phone', 'sender_phone'
    'Phone'
  when :issue_area, 'issue_area'
    'Issue Area'
  when :subject, 'subject'
    'Subject'
  when :message, 'message'
    'Message'
  end
end

def label_text_for(page, node)
  if node.attributes['id']
    l = page.parser.css("label[@for=#{node.attributes['id'].value }]")
    return l.text if l
  end
  
  return ""
end

def make_letter_for_person(person)
  # formageddon can handle a hash

  letter = {}
  letter['email'] = "test@formageddon.com"
  letter['subject'] = "Test Message"
  letter['body'] = "This is a test message testing your service"
  letter['title'] = "Mr."
  letter['first_name'] = "John"
  letter['last_name'] = "Doe"
  letter['address1'] = "123 Someplace Ln."
  letter['city'] = "Some City"
  letter['state'] = person.state

  
  if person.title == 'Rep.'
    zd = ZipcodeDistrict.where(["state=? and district=? and zip5 is not null and zip4 is not null", person.state, person.district]).order('zip4').first
  else
    zd = ZipcodeDistrict.where(["state=? and zip5 is not null and zip4 is not null", person.state]).order('zip4').first
  end
  
  if zd
    letter['zip5'] = zd.zip5
    letter['zip4'] = zd.zip4
  end
  
  letter['issue_area'] = 'Other'
  
  puts "MADE LETTER: #{letter.inspect}"
  letter
end
  
people = Person.all_sitting
#people = Person.where("lastname='Pelosi'")
people.each do |p|
  begin
    unless p.contact_webform.blank? or !p.formageddon_contact_steps.empty?
      puts "Adding step for #{p.name}: visit: #{p.contact_webform}"
      step = Formageddon::FormageddonContactStep.create(:step_number => 1, :command => "visit::#{p.contact_webform}")
      step.formageddon_recipient = p
      step.save
    
      step_number = 1
    
      browser = Mechanize.new
      next_steps = true
      puts "Executing: #{step.command}"
    
      letter = make_letter_for_person(p)

      while (next_steps) do     
        step.execute(browser, {:letter => letter, :save_states => false})
    
        if browser.page.nil? or browser.page.forms.empty?
          puts "Error or found no forms... moving on."
          next_steps = false
        else
          got_form = false
          browser.page.forms.each_with_index do |f, form_index|
            if is_contact_form(browser.page, f)
              puts "Got a contact form: #{f}"
              got_form = true
              step_number += 1
          
              step = Formageddon::FormageddonContactStep.create(:step_number => step_number, :command => "submit_form")
          
              use_field_names = (average_name_length(f) > 30) ? false : true
              f_form = Formageddon::FormageddonForm.create(:form_number => form_index, :use_field_names => use_field_names)
              step.formageddon_recipient = p
              step.formageddon_form = f_form
              step.save
          
              f.fields.each_with_index do |field, field_index|
                puts "Field: #{field.name} => #{predict_selection(browser.page, field.node)}"
            
                f_form.formageddon_form_fields.create(:field_number => field_index, :name => field.name, :value => predict_selection(browser.page, field.node))
              end
            
              if f_form.has_captcha?
                # get the last image?
                imgs = browser.page.parser.css('form')[form_index].css('img')
                unless imgs.empty?
                  f_form.create_formageddon_form_captcha_image(:image_number => (imgs.size - 1), :css_selector => imgs.last.css_path)
                end
              end
            
              if (f.fields.size >= 7 or (f.fields.size < 7 and step_number > 2))
                next_steps = false
              end
            end
          end
        
          next_steps = false unless got_form
        end
      end
    end
  rescue
    puts "GOT AN ERROR: #{$!}"
    next_steps = false
    p.formageddon_contact_steps.clear
  end
end
