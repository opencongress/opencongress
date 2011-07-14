class District < ActiveRecord::Base
  # district_number 0 is reserved for at-large districts

  belongs_to :state
  has_many :watch_dogs
  has_one :current_watch_dog, :class_name => "WatchDog", :conditions => ["is_active = ?", true], :order => "created_at desc"
  has_one :group
  
  def user_count
    User.count_by_solr("my_district:#{self.state.abbreviation}-#{district_number}")    
  end

  def users
    User.find_by_solr("my_district:#{self.state.abbreviation}-#{district_number}", :facets => {:fields => [:public_actions, :public_tracking, :my_bills_supported, :my_bills_opposed, 
                           :my_committees_tracked, :my_bills_tracked, :my_people_tracked, :my_issues_tracked,
                           :my_approved_reps, :my_approved_sens, :my_disapproved_reps, :my_disapproved_sens], :limit => 10, :sort => true, :browse => ["public_tracking:true", "public_actions:true"]}, :order => "last_login desc")
  end
  
  def all_users
    User.find_by_solr("my_district:#{self.state.abbreviation}-#{district_number}", :facets => {:fields => [:public_actions, :public_tracking, :my_bills_supported, :my_bills_opposed, 
                           :my_committees_tracked, :my_bills_tracked, :my_people_tracked, :my_issues_tracked,
                           :my_approved_reps, :my_approved_sens, :my_disapproved_reps, :my_disapproved_sens], :limit => 500, :sort => true}, :order => "last_login desc")
    
  end
  
  def all_active_users

    query = "my_district:#{self.state.abbreviation}-#{district_number} AND last_login:[#{(Time.now - 2.months).iso8601[0,19] + 'Z'} TO *] AND total_number_of_actions:[5 TO *]"
    User.find_by_solr(query, :limit => 500, :order => "last_login desc")
        
  end

  def all_active_users_count
    
    query = "my_district:#{self.state.abbreviation}-#{district_number} AND last_login:[#{(Time.now - 2.months).iso8601[0,19] + 'Z'} TO *] AND total_number_of_actions:[5 TO *]"
    User.count_by_solr(query)

  end

  def self.csv_of_active_users

    require 'csv'
    outfile = File.open('public/active_users_per_district_detailed.csv', 'wb')
    CSV::Writer.generate(outfile) do |csv|
        csv << ['STATE', 'DISTRICT', 'LOGIN', 'LAST LOGIN','TOTAL ACTIONS']
        District.find(:all, :order => ["state_id, district_number asc"]).each do |d|
           d.all_active_users.results.each do |u|
             csv << [d.state.abbreviation,d.district_number,u.login,u.last_login.to_date.to_s,u.total_number_of_actions]
           end
        end
    end
    outfile.close

  end



  def self.csv_of_active_users_count

    require 'csv'
    outfile = File.open('public/active_users_per_district.csv', 'wb')
    CSV::Writer.generate(outfile) do |csv|
        csv << ['STATE', 'DISTRICT', 'TOTAL USERS', 'ACTIVE USERS']

        District.find(:all, :order => ["state_id, district_number asc"]).each do |d|
           csv << [d.state.abbreviation,d.district_number,d.user_count,d.all_active_users_count]
        end
    end
    outfile.close

  end

  def tracking_suggestions
    facets = self.users.facets
    my_trackers = 0
    facet_results_hsh = {:my_bills_supported_facet => [], 
                         :my_people_tracked_facet => [], 
                         :my_issues_tracked_facet => [], 
                         :my_bills_tracked_facet => [],
                         :my_approved_reps_facet => [],
                         :my_approved_sens_facet => [],
                         :my_disapproved_reps_facet => [],
                         :my_disapproved_sens_facet => [],
                         :public_actions_facet => [],
                         :public_tracking_facet => [],
                         :my_committees_tracked_facet => [],
                         :my_bills_opposed_facet => []}
    facet_results_ff = facets['facet_fields']
    if facet_results_ff && facet_results_ff != []
      
      facet_results_ff.each do |fkey, fvalue|
        facet_results = facet_results_ff[fkey]
      
        #solr running through acts as returns as a Hash, or an array if running through tomcat...hence this stuffs
        facet_results_temp_hash = Hash[*facet_results] unless facet_results.class.to_s == "Hash"
        facet_results_temp_hash = facet_results if facet_results.class.to_s == "Hash"
        logger.info facet_results_temp_hash.to_yaml

        facet_results_temp_hash.each do |key,value|
#          if key == self.ident.to_s && fkey == "my_bills_tracked_facet"
#            my_trackers = value
#          else
            logger.info "#{fkey} - #{key} - #{value}"
            unless facet_results_hsh[fkey.to_sym].length == 5
              object = Person.find_by_id(key) if fkey == "my_people_tracked_facet" || fkey =~ /my_approved_/ || fkey =~ /my_disapproved_/
              object = Subject.find_by_id(key) if fkey == "my_issues_tracked_facet"
              object = Bill.find_by_ident(key) if fkey == "my_bills_tracked_facet" 
              object = Bill.find_by_id(key) if fkey =~ /my_bills_supported/ || fkey =~ /my_bills_opposed/
              facet_results_hsh[fkey.to_sym] << {:object => object, :trackers => value}
            end
#          end
        end
      end      
    else
      return [my_trackers,{}]
    end
    unless facet_results_hsh.empty?
      #sort the hashes
      facet_results_hsh[:my_people_tracked_facet].sort!{|a,b| b[:trackers]<=>a[:trackers] }
      facet_results_hsh[:my_issues_tracked_facet].sort!{|a,b| b[:trackers]<=>a[:trackers] }
      facet_results_hsh[:my_bills_tracked_facet].sort!{|a,b| b[:trackers]<=>a[:trackers] }
      facet_results_hsh[:my_approved_sens_facet].sort!{|a,b| b[:trackers]<=>a[:trackers] }
      facet_results_hsh[:my_bills_opposed_facet].sort!{|a,b| b[:trackers]<=>a[:trackers] }
      facet_results_hsh[:my_bills_supported_facet].sort!{|a,b| b[:trackers]<=>a[:trackers] }
      return [my_trackers, facet_results_hsh]
    else
      return [my_trackers,{}]
    end
  end

  def ordinalized_number
    if self.district_number == 0
      "At Large"
    else 
      district_number.ordinalize
    end
  end

  def district_state_text
    self.state.abbreviation + "-" + self.district_number.to_s
  end

  def freebase_guid_url
    if self.district_number == 0
      URI.escape("http://www.freebase.com/api/service/search?query=#{self.state.name}'s congressional district&type=/common/topic&type=/government/political_district")
    else
      URI.escape("http://www.freebase.com/api/service/search?query=#{self.state.name}'s #{self.district_number.ordinalize} congressional district&type=/common/topic&type=/government/political_district")
    end  
  end
  
  def freebase_link
    "http://www.freebase.com/view/en/#{name.downcase.gsub(' ', '_')}"
  end
  
  def freebase_guid
     require 'open-uri'
     require 'json'
     JSON.parse(open(freebase_guid_url).read)['result'].first['article']['id']
  end
  
  def freebase_description_url
    "http://www.freebase.com/api/trans/blurb#{self.freebase_guid}?maxlength=800"
  end

  def freebase_description
     require 'open-uri'
     require 'json'
   begin
    Rails.cache.fetch("district_freebase_desc_#{self.id}") {
        open(freebase_description_url).read.gsub(/\/(.)\(help(.)info\)/,'/')
     }
   rescue
    "Sorry, we couldn't connect to Freebase to give you the description of this district."
   end

  end

  def rep
    Person.rep.find_by_state_and_district(self.state.abbreviation, district_number.to_s)
  end
  
end
