require 'digest/sha1'

# this model expects a certain database layout and its based on the name/login pattern. 
class User < ActiveRecord::Base
  acts_as_solr :fields => [:placeholder, {:definitive_district => :integer},:public_actions,:my_committees_tracked, :my_bills_supported, 
                           :my_people_tracked, :my_bills_opposed, :login, :username, :full_name, :email,
                           :my_approved_reps, :my_approved_sens, :my_disapproved_reps, :my_disapproved_sens,
                           {:my_state => :string}, {:my_district => :string}, 
                           {:total_number_of_actions => :range_integer}, :my_bills_tracked, :public_tracking, 
                           :my_issues_tracked, :my_state_f, :my_district_f, {:last_login => :date}], 
               :facets => [:public_actions, :public_tracking, :my_bills_supported, :my_bills_opposed, 
                           :my_committees_tracked, :my_bills_tracked, :my_people_tracked, :my_issues_tracked,
                           :my_approved_reps, :my_approved_sens, :my_disapproved_reps, 
                           :my_disapproved_sens, :my_state_f, :my_district_f], :auto_commit => false

  attr_accessor :password

  validates_presence_of     :login, :email, :unless => :openid?
  validates_acceptance_of :accept_tos, :on => :create
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40, :unless => :openid?
  validates_length_of       :zip_four, :within => 0..4, :allow_nil => true, :allow_blank => true
  validates_length_of       :email,    :within => 3..100, :unless => :openid?
  #validates_email_veracity_of :email
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "address invalid"
  validates_numericality_of :zipcode, :only_integer => true, :allow_nil => true, :message => "is not a valid 5 digit zipcode"
  validates_numericality_of :zip_four, :only_integer => true, :allow_nil => true, :message => "is not a valid 4 digit zipcode extension"
  validates_length_of :zipcode, :is => 5, :allow_nil => true, :message => "is not a valid 5 digit zipcode"
  validates_length_of :zip_four, :is => 4, :allow_nil => true, :message => "is not a valid 4 digit zipcode extension"
  validates_format_of :login, :with => /^\w+$/, :message => "can only contain letters and numbers (no spaces)."
  validates_uniqueness_of   :login, :email, :identity_url, :case_sensitive => false, :allow_nil => true

  HUMANIZED_ATTRIBUTES = {
    :email => "E-mail address",
    :accept_tos => "Terms of service",
    :zip_four => "ZIP code +4 extension",
    :zipcode => "ZIP code",
    :login => "Username",
    :partner_mailing => "Partner mailing preference"
  }

  before_create :make_activation_code
  after_create :make_feed_key
  after_create :make_privacy_options
  before_save :encrypt_password
  
  # district and state information is cached to save some db queries
  before_save :cache_district_and_state
  serialize :district_cache
  serialize :state_cache
  
  has_many :api_hits
  has_many :comments
  has_one  :privacy_option
  has_one :user_mailing_list
  has_one :twitter_config
  has_many :person_approvals
  has_many :commentary_ratings
  has_many :bill_votes
  has_many :comment_scores
  has_many :bookmarks
  has_many :user_ip_addresses
  has_one :latest_ip_address, :class_name => "UserIpAddress", :order => "created_at DESC"
  has_many :friends
  has_many :friend_invites, :foreign_key => "inviter_id"
  has_many :fans, :class_name => "Friend", :foreign_key => "friend_id", :conditions => ["confirmed = ?", false]
  has_many :senator_bookmarks, :class_name => "Bookmark", :foreign_key => "user_id", :include => [:person], :conditions => ["people.name like ?", "Sen.%"]
  has_many :representative_bookmarks, :class_name => "Bookmark", :foreign_key => "user_id", :include => [:person], :conditions => ["people.name like ?", "Rep.%"]
  has_many :bill_bookmarks, :class_name => "Bookmark", :foreign_key => "user_id", :conditions => "bookmarks.bookmarkable_type = 'Bill'"
  has_many :issue_bookmarks, :class_name => "Bookmark", :foreign_key => "user_id", :conditions => "bookmarks.bookmarkable_type = 'Subject'"
  has_many :committee_bookmarks, :class_name => "Bookmark", :foreign_key => "user_id", :conditions => "bookmarks.bookmarkable_type = 'Committee'"

  has_many :watched_districts, :class_name => "WatchDog"


  has_many :bookmarked_bills, :class_name => "Bill", 
                              :finder_sql => 'select bills.*, bm.bookmarkers FROM bills 
                                 INNER JOIN (select bookmarks.bookmarkable_type, bookmarks.user_id, 
             bookmarks.bookmarkable_id, bookmarks.created_at FROM bookmarks) b ON b.bookmarkable_id = bills.id
                                 LEFT JOIN (select count(user_id) as bookmarkers, bookmarkable_id
                                 from bookmarks WHERE bookmarkable_type = \'Bill\'
                                 group by bookmarkable_id) bm ON bm.bookmarkable_id = bills.id
                           WHERE b.bookmarkable_type = \'Bill\' AND b.user_id = #{id}
                           ORDER BY b.created_at'

  
  has_many :bills_supported, :class_name => "Bill", 
                              :finder_sql => 'select bills.* FROM bills 
                                 INNER JOIN (select bill_votes.support, bill_votes.user_id, 
                                    bill_votes.created_at, bill_votes.bill_id FROM bill_votes WHERE bill_votes.support = 0
                                    AND bill_votes.user_id = #{id}) b ON b.bill_id = bills.id
                                 ORDER BY b.created_at'

  
  has_many :bills_opposed, :class_name => "Bill", 
                              :finder_sql => 'select bills.* FROM bills 
                                  INNER JOIN (select bill_votes.support, bill_votes.user_id, 
                                   bill_votes.created_at, bill_votes.bill_id FROM bill_votes WHERE bill_votes.support = 1
                                  AND bill_votes.user_id = #{id}) b ON b.bill_id = bills.id
                                  ORDER BY b.created_at'
  
  has_many :bookmarked_senators, :class_name => "Person", 
                              :finder_sql => 'select people.* FROM people 
                                                INNER JOIN (select bookmarks.bookmarkable_type, bookmarks.user_id, 
                                                  bookmarks.bookmarkable_id, bookmarks.created_at FROM bookmarks) b ON b.bookmarkable_id = people.id
                                                WHERE people.name like \'Sen.%\' AND b.bookmarkable_type = \'Person\' AND b.user_id = #{id}
                                                ORDER BY b.created_at'


  
  has_many :bookmarked_representatives, :class_name => "Person", 
                              :finder_sql => 'select people.* FROM people 
                                                INNER JOIN (select bookmarks.bookmarkable_type, bookmarks.user_id, 
                                                  bookmarks.bookmarkable_id, bookmarks.created_at FROM bookmarks) b ON b.bookmarkable_id = people.id
                                                WHERE people.name like \'Rep.%\' AND b.bookmarkable_type = \'Person\' AND b.user_id = #{id}
                                                ORDER BY b.created_at'

  has_many :bookmarked_people, :class_name => "Person", 
                              :finder_sql => 'select people.* FROM people 
                                                INNER JOIN (select bookmarks.bookmarkable_type, bookmarks.user_id, 
                                                  bookmarks.bookmarkable_id, bookmarks.created_at FROM bookmarks) b ON b.bookmarkable_id = people.id
                                                WHERE b.bookmarkable_type = \'Person\' AND b.user_id = #{id}
                                                ORDER BY b.created_at'
  
  has_many :bookmarked_issues, :class_name => "Subject", 
                              :finder_sql => 'select subjects.* FROM subjects 
                                                INNER JOIN (select bookmarks.bookmarkable_type, bookmarks.user_id, 
                                                  bookmarks.bookmarkable_id, bookmarks.created_at FROM bookmarks) b ON b.bookmarkable_id = subjects.id
                                                WHERE b.bookmarkable_type = \'Subject\' AND b.user_id = #{id}
                                                ORDER BY b.created_at'

  has_many :bookmarked_committees, :class_name => "Committee",
                              :finder_sql => 'select committees.* FROM committees
                                                INNER JOIN (select bookmarks.bookmarkable_type, bookmarks.user_id,
                                                  bookmarks.bookmarkable_id, bookmarks.created_at FROM bookmarks) b ON b.bookmarkable_id = committees.id
                                                WHERE b.bookmarkable_type = \'Committee\' AND b.user_id = #{id}
                                                ORDER BY b.created_at'

  belongs_to :representative, :class_name => "Person", :foreign_key => "representative_id"
  belongs_to :user_role
  has_one :watch_dog
  has_many :user_warnings
  
  has_one :political_notebook
  has_many :notebook_items, :through => :political_notebook
  
#  has_many :bill_comments
  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  def placeholder
    "placeholder"
  end

  def username
    login
  end

  def total_number_of_actions
    self.comments.count + self.friends.count + self.bill_votes.count + self.person_approvals.count + self.bookmarks.count
  end

  def my_state
    ZipcodeDistrict.zip_lookup(self.zipcode, self.zip_four).collect {|p| p.state}.uniq
  end
  
  def my_district
    ZipcodeDistrict.zip_lookup(self.zipcode, self.zip_four).collect {|p| "#{p.state}-#{p.district}"}.uniq
  end
  def my_district_number
    ZipcodeDistrict.zip_lookup(self.zipcode, self.zip_four).collect {|p| "#{p.district}"}.uniq
  end
  def definitive_district
    if self.my_district.compact.length == 1
       t_state, t_district = self.my_district.first.split('-')
       this_state = State.find_by_abbreviation(t_state)
       this_district = this_state.districts.find_by_district_number(t_district) if this_state
       if this_district
         return this_district.id
       else
         return nil
       end
    else
      return nil
    end
 
  end
  
  def my_state_f
    self.my_state
  end
  
  def my_district_f
    self.my_district
  end
  
  def definitive_district_object
    if self.my_district.compact.length == 1
       t_state, t_district = self.my_district.first.split('-')
       this_state = State.find_by_abbreviation(t_state)
       this_district = this_state.districts.find_by_district_number(t_district) if this_state
       if this_district
         return this_district
       else
         return nil
       end
    else
      return nil
    end
  end
  
  def friends_in_state(state = self.my_state)
    unless self.my_state.empty? 
      friends_logins = friends.collect{|p| "login:#{p.friend.login}"}
      unless friends_logins.empty?
        User.find_by_solr("#{friends_logins.join(' OR ')}", 
             :facets => {:browse => ["my_state_f:\"#{self.my_state}\""]}, :limit => 100).results
      else
        return []
      end
    else
      return []
    end
  end

  def friends_in_district(district = self.my_district)
    unless self.my_district.empty?
      friends_logins = friends.collect{|p| "login:#{p.friend.login}"}
      unless friends_logins.empty?
        User.find_by_solr("#{friends_logins.join(' OR ')}", 
          :facets => {:browse => ["my_district_f:#{self.my_district}"]}, :limit => 100).results
      else
        return []
      end
    else
      return []
    end
  end
  
  def my_sens
    Person.find_current_senators_by_state(self.my_state)
  end
  def my_reps
    Person.find_current_representatives_by_state_and_district(self.my_state, self.my_district_number)  
  end
 
  def my_approved_reps
    self.person_approvals.find(:all, :include => [:person], :conditions => ["people.name LIKE ? AND rating > 5", '%Rep.%']).collect {|p| p.person.id}
  end
  
  def my_disapproved_reps
    self.person_approvals.find(:all, :include => [:person], :conditions => ["people.name LIKE ? AND rating <= 5", '%Rep.%']).collect {|p| p.person.id}
  end

  def my_approved_sens
    self.person_approvals.find(:all, :include => [:person], :conditions => ["people.name LIKE ? AND rating > 5", '%Sen.%']).collect {|p| p.person.id}
  end
  
  def my_disapproved_sens
    self.person_approvals.find(:all, :include => [:person], :conditions => ["people.name LIKE ? AND rating <= 5", '%Sen.%']).collect {|p| p.person.id}
  end
  
  def public_actions
    self.can_view(:my_actions, nil)
  end

  def my_bills_supported
    self.bills_supported.collect{|p| p.id}
  end

  def my_bills_opposed
    self.bills_opposed.collect{|p| p.id}
  end

  def my_bills_tracked
    self.bookmarked_bills.collect{|p| p.ident}
  end

  def my_committees_tracked
    self.bookmarked_committees.collect{|p| p.id}
  end
  
  def my_people_tracked
    self.bookmarked_people.collect{|p| p.id}
  end
  
  def my_issues_tracked
    self.bookmarked_issues.collect{|p| p.id}
  end

  def public_tracking
    if self.privacy_option['my_tracked_items'] == 2
       return true
    else
       return false
    end
  end

  
  def votes_like_me
    req = []
    self.my_bills_supported.each do |b|
      req << "my_bills_supported:#{b}"
    end
    self.my_bills_opposed.each do |b|
      req << "my_bills_opposed:#{b}"
    end
    
    unless req.empty? 
      query = req.join(' OR ')  
      return User.find_by_solr(query, :scores => true, :limit => 31, :facets => {:zeros => true, :browse => ["public_actions:true"] }).results
    else
      return nil
    end
  end

  def find_other_users_in_state(state)
    User.find_by_sql(['select distinct users.id, users.login from users where state_cache like ?;', "%#{state}%"])
  end

  def find_other_users_in_district(state, district)
    User.find_by_sql(['select distinct users.id, users.login from users where district_cache like ?;', "%#{state}-#{district}%"])
  end

  
  def senator_bookmarks_count
    current_user.bookmarks.count(:all, :include => [{:person => :roles}], :conditions => ["roles.role_type = ?", "sen"])
  end
  def representative_bookmarks_count
    current_user.bookmarks.count(:all, :include => [{:person => :roles}], :conditions => ["roles.role_type = ?", "rep"])
  end


  class << self
    def find_users_in_districts_tracking(districts, object, limit)
      query = "my_district:(#{districts.join(' OR ')})"
      case object.class.to_s
      when 'Person'
        User.find_id_by_solr(query, :facets => {:browse => ["public_tracking:true", "my_people_tracked:#{object.id}"]}, :limit => limit)
      when 'Bill'
        User.find_id_by_solr(query, :facets => {:browse => ["public_tracking:true", "my_bills_tracked:#{object.ident}"]}, :limit => limit)
      when 'Subject'
        User.find_id_by_solr(query, :facets => {:browse => ["public_tracking:true", "my_issues_tracked:#{object.id}"]}, :limit => limit)
      when 'Committee'
        User.find_id_by_solr(query, :facets => {:browse => ["public_tracking:true", "my_committees_tracked:#{object.id}"]}, :limit => limit)
      end      
    end
  
    def find_users_in_districts_supporting(districts, object, limit)
      query = "my_district:(#{districts.join(' OR ')})"
      case object.class.to_s
        when 'Person'
          case object.title
            when 'Rep.'
              User.find_id_by_solr(query, :facets => {:browse => ["public_tracking:true", "my_approved_reps:#{object.id}"]}, :limit => limit)
            when 'Sen.'
              User.find_id_by_solr(query, :facets => {:browse => ["public_tracking:true", "my_approved_sens:#{object.id}"]}, :limit => limit)
          end
        when 'Bill'
          User.find_id_by_solr(query, :facets => {:browse => ["public_actions:true", "my_bills_supported:#{object.id}"]}, :limit => limit)
      end
    end

    def find_users_in_districts_opposing(districts, object, limit)
      query = "my_district:(#{districts.join(' OR ')})"
      case object.class.to_s
        when 'Person'
          case object.title
            when 'Rep.'
              User.find_id_by_solr(query, :facets => {:browse => ["public_tracking:true", "my_disapproved_reps:#{object.id}"]}, :limit => limit)
            when 'Sen.'
              User.find_id_by_solr(query, :facets => {:browse => ["public_tracking:true", "my_disapproved_sens:#{object.id}"]}, :limit => limit)
          end
        when 'Bill'
          User.find_id_by_solr(query, :facets => {:browse => ["public_actions:true", "my_bills_opposed:#{object.id}"]}, :limit => limit)
      end
    end

    def find_users_in_states_supporting(states, object, limit)
      query = "my_state:(\"#{states.join('" OR "')}\")"
      case object.class.to_s
        when 'Person'
          case object.title
            when 'Rep.'
              User.find_id_by_solr(query, :facets => {:browse => ["public_tracking:true", "my_approved_reps:#{object.id}"]}, :limit => limit)
            when 'Sen.'
              User.find_id_by_solr(query, :facets => {:browse => ["public_tracking:true", "my_approved_sens:#{object.id}"]}, :limit => limit)
          end
        when 'Bill'
          User.find_id_by_solr(query, :facets => {:browse => ["public_actions:true", "my_bills_supported:#{object.id}"]}, :limit => limit)
      end
    end

    def find_users_in_states_opposing(states, object, limit)
      query = "my_state:(\"#{states.join('" OR "')}\")"
      case object.class.to_s
        when 'Person'
          case object.title
            when 'Rep.'
              User.find_id_by_solr(query, :facets => {:browse => ["public_tracking:true", "my_disapproved_reps:#{object.id}"]}, :limit => limit)
            when 'Sen.'
              User.find_id_by_solr(query, :facets => {:browse => ["public_tracking:true", "my_disapproved_sens:#{object.id}"]}, :limit => limit)
          end
        when 'Bill'
          User.find_id_by_solr(query, :facets => {:browse => ["public_actions:true", "my_bills_opposed:#{object.id}"]}, :limit => limit)
      end
    end
          
    def find_users_in_states_tracking(states, object, limit)
      query = "my_state:(\"#{states.join('" OR "')}\")"
      case object.class.to_s
      when 'Person'
        User.find_id_by_solr(query, :facets => {:browse => ["public_tracking:true", "my_people_tracked:#{object.id}"]}, :limit => limit)
      when 'Bill'
        User.find_id_by_solr(query, :facets => {:browse => ["public_tracking:true", "my_bills_tracked:#{object.ident}"]}, :limit => limit)
      when 'Subject'
        User.find_id_by_solr(query, :facets => {:browse => ["public_tracking:true", "my_issues_tracked:#{object.id}"]}, :limit => limit)
      when 'Committee'
        User.find_id_by_solr(query, :facets => {:browse => ["public_tracking:true", "my_committees_tracked:#{object.id}"]}, :limit => limit)
      end 
    end

    def find_users_tracking_bill(bill)
      #find(:all, :include => [:bookmarks, :privacy_option], :conditions => ["bookmarkable_type = 'Bill' AND bookmarkable_id = ? AND privacy_options.my_tracked_items = ?", bill.id, 2], :order => "users.login")
       find_id_by_solr('placeholder:placeholder', :facets => {:browse => ["my_bills_tracked:#{bill.ident}", "public_tracking:true"]}, :limit => 1000)
    end

    def find_users_tracking_person(person)
  #    find(:all, :include => [:bookmarks, :privacy_option], :conditions => ["bookmarkable_type = 'Person' AND bookmarkable_id = ? AND privacy_options.my_tracked_items = ?", person.id, 2], :order => "users.login")
       find_id_by_solr('placeholder:placeholder', :facets => {:browse => ["my_people_tracked:#{person.id}","public_tracking:true"]}, :limit => 1000)
    end

    def find_users_tracking_issue(issue)
  #    find(:all, :include => [:bookmarks, :privacy_option], :conditions => ["bookmarkable_type = 'Subject' AND bookmarkable_id = ? AND privacy_options.my_tracked_items = ?", issue.id, 2], :order => "users.login")
       find_id_by_solr('placeholder:placeholder', :facets => {:browse => ["my_issues_tracked:#{issue.id}","public_tracking:true"]}, :limit => 1000)
    end

    def find_users_opposing_bill(bill)
          find_id_by_solr('placeholder:placeholder', :facets => {:browse => ["public_actions:true", "my_bills_opposed:#{bill.id}"]}, :limit => 1000)
    end

    def find_users_supporting_bill(bill)
          find_id_by_solr('placeholder:placeholder', :facets => {:browse => ["public_actions:true", "my_bills_supported:#{bill.id}"]}, :limit => 1000)
    end

    def find_users_supporting_person(person)
      case person.title
        when 'Rep.'
          User.find_id_by_solr('placeholder:placeholder', :facets => {:browse => ["public_tracking:true", "my_approved_reps:#{person.id}"]}, :limit => 1000)
        when 'Sen.'
          User.find_id_by_solr('placeholder:placeholder', :facets => {:browse => ["public_tracking:true", "my_approved_sens:#{person.id}"]}, :limit => 1000)
      end    
    end

    def find_users_opposing_person(person)
      case person.title
        when 'Rep.'
          User.find_id_by_solr('placeholder:placeholder', :facets => {:browse => ["public_tracking:true", "my_disapproved_reps:#{person.id}"]}, :limit => 1000)
        when 'Sen.'
          User.find_id_by_solr('placeholder:placeholder', :facets => {:browse => ["public_tracking:true", "my_disapproved_sens:#{person.id}"]}, :limit => 1000)
      end    
    end

 
    def find_users_tracking_committee(committee)
  #    find(:all, :include => [:bookmarks, :privacy_option], :conditions => ["bookmarkable_type = 'Subject' AND bookmarkable_id = ? AND privacy_options.my_tracked_items = ?", issue.id, 2], :order => "users.login")
       find_id_by_solr('placeholder:placeholder', :facets => {:browse => ["my_committees_tracked:#{committee.id}","public_tracking:true"]}, :limit => 1000)
    end

    def highest_rated_commenters
      cs = CommentScore.calculate(:count, :score, :include => "comment", :group => "comments.user_id", :order => "count_score DESC").collect {|p| p[1] > 3 && p[0] != nil ? p[0] : nil}.compact
      CommentScore.calculate(:avg, :score, :include => "comment", :group => "comments.user_id", :conditions => ["comments.user_id in (?)", cs], :order => "avg_score DESC").each do |k|
        puts "#{User.find_by_id(k[0]).login} - Average Rating: #{k[1]}"
      end
    end

    # state, district, location_allowed (permissions options), total site actions ( votes, comments, friends ) 
    # user_vote, user_approval
    def find_for_tracking_table(logged_in_user, object, ids)
       this_user = nil
       this_user = logged_in_user.id if logged_in_user
       case object.class.to_s
         when 'Person'
             find_by_sql(["select users.*, po.my_location as location_allowed, po.my_actions as actions_allowed, po.my_congressional_district, po.my_last_login_date as last_login_allowed, 
                               COALESCE(comments2.tc,0) as total_comments, COALESCE(bill_votes_agg.tc, 0) + COALESCE(user_votes.tc, 0) + COALESCE(user_votes2.tc,0) + COALESCE(comments.tc,0) + COALESCE(friends.tc,0) as total_actions,
                               person_approvals.rating as object_rating, fri.friend_id as is_friend, fri.confirmed as is_friend_confirmed FROM users
                                LEFT OUTER JOIN ( select privacy_options.my_congressional_district, privacy_options.my_last_login_date, privacy_options.my_location, privacy_options.my_actions, 
                                privacy_options.user_id from privacy_options where privacy_options.user_id in (?))
                                    po ON po.user_id = users.id
                                LEFT OUTER JOIN ( select bill_votes.user_id, count(bill_votes.id) as tc from bill_votes WHERE bill_votes.user_id in (?) group by bill_votes.user_id)
                                    user_votes ON user_votes.user_id = users.id
                                LEFT OUTER JOIN ( select person_approvals.user_id, count(person_approvals.id) as tc from person_approvals WHERE person_approvals.user_id in (?)
                                    group by person_approvals.user_id)
                                    user_votes2 ON user_votes2.user_id = users.id
                                LEFT OUTER JOIN ( select comments.user_id, count(comments.id) as tc from comments WHERE comments.user_id in (?) group by comments.user_id)
                                    comments ON comments.user_id = users.id
                                LEFT OUTER JOIN ( select bill_votes.user_id, count(bill_votes.id) as tc from bill_votes WHERE bill_votes.user_id in (?) group by bill_votes.user_id)
                                    bill_votes_agg ON bill_votes_agg.user_id = users.id
                                LEFT OUTER JOIN ( select friends.user_id, count(friends.user_id) as tc from friends WHERE friends.user_id in (?) AND friends.confirmed = ? group by friends.user_id)
                                    friends ON friends.user_id = users.id
                                LEFT OUTER JOIN ( select count(id) as tc, user_id FROM comments WHERE user_id IN (?) AND commentable_type = 'Person' AND commentable_id = ? group by comments.user_id)
                                    comments2 ON comments2.user_id = users.id
                                LEFT OUTER JOIN ( select friends.user_id, friends.friend_id, friends.confirmed from friends WHERE friends.friend_id in (?) AND friends.user_id = (?))
                                    fri ON fri.friend_id = users.id
                                LEFT OUTER JOIN ( select person_approvals.rating, person_approvals.user_id FROM person_approvals WHERE person_approvals.user_id in (?) AND person_approvals.person_id = ?)
                                    person_approvals ON person_approvals.user_id = users.id
                                WHERE users.id in (?)", ids, ids, ids, ids, ids, ids, true, ids, object.id, ids, this_user, ids, object.id, ids])
         when 'Bill'
             find_by_sql(["select users.*, po.my_location as location_allowed, po.my_actions as actions_allowed, po.my_congressional_district, po.my_last_login_date as last_login_allowed, 
                               COALESCE(comments2.tc,0) as total_comments, COALESCE(bill_votes_agg.tc, 0) + COALESCE(user_votes.tc, 0) + COALESCE(user_votes2.tc,0) + COALESCE(comments.tc,0) + COALESCE(friends.tc,0) as total_actions,
                               bill_votes.support as support, fri.friend_id as is_friend, fri.confirmed as is_friend_confirmed FROM users
                                LEFT OUTER JOIN ( select privacy_options.my_congressional_district, privacy_options.my_last_login_date, privacy_options.my_location, privacy_options.my_actions, 
                                privacy_options.user_id from privacy_options where privacy_options.user_id in (?))
                                    po ON po.user_id = users.id
                                LEFT OUTER JOIN ( select bill_votes.user_id, count(bill_votes.id) as tc from bill_votes WHERE bill_votes.user_id in (?) group by bill_votes.user_id)
                                    user_votes ON user_votes.user_id = users.id
                                LEFT OUTER JOIN ( select person_approvals.user_id, count(person_approvals.id) as tc from person_approvals WHERE person_approvals.user_id in (?)
                                    group by person_approvals.user_id)
                                    user_votes2 ON user_votes2.user_id = users.id
                                LEFT OUTER JOIN ( select comments.user_id, count(comments.id) as tc from comments WHERE comments.user_id in (?) group by comments.user_id)
                                    comments ON comments.user_id = users.id
                                LEFT OUTER JOIN ( select bill_votes.user_id, count(bill_votes.id) as tc from bill_votes WHERE bill_votes.user_id in (?) group by bill_votes.user_id)
                                    bill_votes_agg ON bill_votes_agg.user_id = users.id
                                LEFT OUTER JOIN ( select friends.user_id, count(friends.user_id) as tc from friends WHERE friends.user_id in (?) AND friends.confirmed = ? group by friends.user_id)
                                    friends ON friends.user_id = users.id
                                LEFT OUTER JOIN ( select count(id) as tc, user_id FROM comments WHERE user_id IN (?) AND commentable_type = 'Bill' AND commentable_id = ? group by comments.user_id)
                                    comments2 ON comments2.user_id = users.id
                                LEFT OUTER JOIN ( select friends.user_id, friends.friend_id, friends.confirmed from friends WHERE friends.friend_id in (?) AND friends.user_id = (?))
                                    fri ON fri.friend_id = users.id
                                LEFT OUTER JOIN ( select bill_votes.support, bill_votes.user_id FROM bill_votes WHERE bill_votes.user_id in (?) AND bill_votes.bill_id = ?) 
                                    bill_votes ON bill_votes.user_id = users.id
                                WHERE users.id in (?)", ids, ids, ids, ids, ids, ids, true, ids, object.id, ids, this_user, ids, object.id, ids])
         when 'Subject'
             find_by_sql(["select users.*, po.my_location as location_allowed, po.my_actions as actions_allowed, po.my_congressional_district, po.my_last_login_date as last_login_allowed, 
                               COALESCE(comments2.tc,0) as total_comments, COALESCE(bill_votes_agg.tc, 0) + COALESCE(user_votes.tc, 0) + COALESCE(user_votes2.tc,0) + COALESCE(comments.tc,0) + COALESCE(friends.tc,0) as total_actions,
                               fri.friend_id as is_friend, fri.confirmed as is_friend_confirmed FROM users
                                LEFT OUTER JOIN ( select privacy_options.my_congressional_district, privacy_options.my_last_login_date, privacy_options.my_location, privacy_options.my_actions, 
                                privacy_options.user_id from privacy_options where privacy_options.user_id in (?))
                                    po ON po.user_id = users.id
                                LEFT OUTER JOIN ( select bill_votes.user_id, count(bill_votes.id) as tc from bill_votes WHERE bill_votes.user_id in (?) group by bill_votes.user_id)
                                    user_votes ON user_votes.user_id = users.id
                                LEFT OUTER JOIN ( select person_approvals.user_id, count(person_approvals.id) as tc from person_approvals WHERE person_approvals.user_id in (?)
                                    group by person_approvals.user_id)
                                    user_votes2 ON user_votes2.user_id = users.id
                                LEFT OUTER JOIN ( select comments.user_id, count(comments.id) as tc from comments WHERE comments.user_id in (?) group by comments.user_id)
                                    comments ON comments.user_id = users.id
                                LEFT OUTER JOIN ( select bill_votes.user_id, count(bill_votes.id) as tc from bill_votes WHERE bill_votes.user_id in (?) group by bill_votes.user_id)
                                    bill_votes_agg ON bill_votes_agg.user_id = users.id
                                LEFT OUTER JOIN ( select friends.user_id, count(friends.user_id) as tc from friends WHERE friends.user_id in (?) AND friends.confirmed = ? group by friends.user_id)
                                    friends ON friends.user_id = users.id
                                LEFT OUTER JOIN ( select count(id) as tc, user_id FROM comments WHERE user_id IN (?) AND commentable_type = 'Subject' AND commentable_id = ? group by comments.user_id)
                                    comments2 ON comments2.user_id = users.id
                                LEFT OUTER JOIN ( select friends.user_id, friends.friend_id, friends.confirmed from friends WHERE friends.friend_id in (?) AND friends.user_id = (?))
                                    fri ON fri.friend_id = users.id
                                WHERE users.id in (?)", ids, ids, ids, ids, ids, ids, true, ids, object.id, ids, this_user, ids])
         when 'Committee'
             find_by_sql(["select users.*, po.my_location as location_allowed, po.my_actions as actions_allowed, po.my_congressional_district, po.my_last_login_date as last_login_allowed, 
                               COALESCE(comments2.tc,0) as total_comments, COALESCE(bill_votes_agg.tc, 0) + COALESCE(user_votes.tc, 0) + COALESCE(user_votes2.tc,0) + COALESCE(comments.tc,0) + COALESCE(friends.tc,0) as total_actions,
                               fri.friend_id as is_friend, fri.confirmed as is_friend_confirmed FROM users
                                LEFT OUTER JOIN ( select privacy_options.my_congressional_district, privacy_options.my_last_login_date, privacy_options.my_location, privacy_options.my_actions, 
                                privacy_options.user_id from privacy_options where privacy_options.user_id in (?))
                                    po ON po.user_id = users.id
                                LEFT OUTER JOIN ( select bill_votes.user_id, count(bill_votes.id) as tc from bill_votes WHERE bill_votes.user_id in (?) group by bill_votes.user_id)
                                    user_votes ON user_votes.user_id = users.id
                                LEFT OUTER JOIN ( select person_approvals.user_id, count(person_approvals.id) as tc from person_approvals WHERE person_approvals.user_id in (?)
                                    group by person_approvals.user_id)
                                    user_votes2 ON user_votes2.user_id = users.id
                                LEFT OUTER JOIN ( select comments.user_id, count(comments.id) as tc from comments WHERE comments.user_id in (?) group by comments.user_id)
                                    comments ON comments.user_id = users.id
                                LEFT OUTER JOIN ( select bill_votes.user_id, count(bill_votes.id) as tc from bill_votes WHERE bill_votes.user_id in (?) group by bill_votes.user_id)
                                    bill_votes_agg ON bill_votes_agg.user_id = users.id
                                LEFT OUTER JOIN ( select friends.user_id, count(friends.user_id) as tc from friends WHERE friends.user_id in (?) AND friends.confirmed = ? group by friends.user_id)
                                    friends ON friends.user_id = users.id
                                LEFT OUTER JOIN ( select count(id) as tc, user_id FROM comments WHERE user_id IN (?) AND commentable_type = 'Committee' AND commentable_id = ? group by comments.user_id)
                                    comments2 ON comments2.user_id = users.id
                                LEFT OUTER JOIN ( select friends.user_id, friends.friend_id, friends.confirmed from friends WHERE friends.friend_id in (?) AND friends.user_id = (?))
                                    fri ON fri.friend_id = users.id
                                WHERE users.id in (?)", ids, ids, ids, ids, ids, ids, true, ids, object.id, ids, this_user, ids])
       end
    end 
 
    def find_all_by_ip(address)
       ip = UserIpAddress.int_form(address)
       self.find(:all, :include => [:user_ip_addresses], :conditions => ["user_ip_addresses.addr = ?", ip])
    end

 end # class << self
 
  # permissions method
  def can_view(option,viewer)
    res = false
    if viewer.nil?
      logger.info "tis nil"
      if self.privacy_option[option] == 2
        logger.info "tis allowed"
        res = true
      else
        logger.info "tis not allowed"
        res = false
      end
    elsif viewer[:id] == self[:id]
      res = true
    elsif self.friends.find_by_friend_id(viewer[:id]) && self.privacy_option[option] >= 1
      res = true
    elsif self.privacy_option[option] == 2
      res = true
    else
      res = false
    end
    return res
  end

  # use only on the users tracking x are also tracking y friends pages /friends/tracking_person, etc.
  def can_view_special(field)
    if self[field] == '2' || ( self[field] == '1' && (self['is_friend'] && self['is_friend_confirmed'] == 't'))
      return true
    else
      return false
    end
  end
  
  def recent_actions(limit = 10)
    b = self.bookmarks.find(:all, :order => "created_at DESC", :limit => limit)
    c = self.comments.find(:all, :order => "created_at DESC", :limit => limit)
    bv = self.bill_votes.find(:all, :order => "created_at DESC", :limit => limit)
    pa = self.person_approvals.find(:all, :order => "created_at DESC", :limit => limit)
    f = self.friends.find(:all, :conditions => ["confirmed = ?", true], :order => "confirmed_at DESC", :limit => limit)
    items = b.concat(c).concat(bv).concat(pa).concat(f).compact
    items.sort! { |x,y| y.created_at <=> x.created_at }
    return items
  end

  def recent_public_actions(limit = 10)
#    b = self.bookmarks.find(:all, :order => "created_at DESC", :limit => limit)
    c = self.comments.find(:all, :order => "created_at DESC", :limit => limit)
    bv = self.bill_votes.find(:all, :order => "created_at DESC", :limit => limit)
#    pa = self.person_approvals.find(:all, :order => "created_at DESC", :limit => limit)
    f = self.friends.find(:all, :conditions => ["confirmed = ?", true], :order => "confirmed_at DESC", :limit => limit)
    items = c.concat(bv).concat(f).compact
    items.sort! { |x,y| y.created_at <=> x.created_at }
    return items
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
     u = find :first, :conditions => ['LOWER(login) = ? and activated_at IS NOT NULL and enabled = true AND is_banned != true', login.downcase]
     if u && u.authenticated?(password)
#        u.update_attribute(:previous_login_date, u.last_login ? u.last_login : Time.now)
#        u.update_attribute(:last_login, Time.now)
        u
     else
       nil
     end
  end
    # Activates the user in the database.
    def activate
      @activated = true
      update_attributes(:activated_at => Time.now.utc, :activation_code => nil)
    end

    # Returns true if the user has just been activated.
    def recently_activated?
      @activated
    end
  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  def check_feed_key
    unless self.feed_key
      self.update_attribute(:feed_key, Digest::SHA1.hexdigest("--#{self.login}--#{self.email}--ASDFASDFASDF@ASDFKTWDS"))
    end
  end    

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 8.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

   def forgot_password
     @forgotten_password = true
     self.make_password_reset_code
   end

   def reset_password
     # First update the password_reset_code before setting the
     # reset_password flag to avoid duplicate email notifications.
     update_attributes(:password_reset_code => nil)
     @reset_password = true
     self.activate if self.activated_at.nil?
   end

   def recently_reset_password?
     @reset_password
   end

   def recently_forgot_password?
     @forgotten_password
   end

   def comment_warn(comment, admin)
     self.user_warnings.create({:warning_message => "Comment Warning for Comment #{comment.id}", :warned_by => admin.id})
     if Rails.env.production?
       UserNotifier.deliver_comment_warning(self, comment)
     end
   end

   def self.fix_duplicate_users
     User.find_by_sql('select login, COUNT(*) as r1_tally FROM users GROUP BY login HAVING COUNT(*) > 1 ORDER BY r1_tally desc;').each do |k|
       puts k.login
       number = k.r1_tally.to_i
       User.find_all_by_login(k.login, :order => "created_at desc").each do |j|
          number = number - 1
          j.destroy unless number == 1
       end
     end
     User.find_by_sql('select email, COUNT(*) as r1_tally FROM users GROUP BY email HAVING COUNT(*) > 1 ORDER BY r1_tally desc;').each do |k|
       puts k.email
       number = k.r1_tally.to_i
       User.find_all_by_email(k.email, :order => "created_at desc").each do |j|
          number = number - 1
          j.destroy unless number == 1
       end
     end
     User.find_by_sql('select lower(login) as login, COUNT(*) as r1_tally FROM users GROUP BY login HAVING COUNT(*) > 1 ORDER BY r1_tally desc;').each do |k|
       next if k.nil?
       puts k.login
       number = k.r1_tally.to_i
       k.destroy if k.activated_at.nil?
     end

   end

   protected

   def make_password_reset_code
     self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
   end

    # before filter
   def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
   end
   def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
      
   end

   def make_feed_key
     self.check_feed_key
   end
   
   def make_privacy_options
     PrivacyOption.create({:user_id => self.id})
   end

   def password_required?
     !openid? && ( crypted_password.blank? || !password.blank? )
   end

   def openid?
    !identity_url.blank?
   end
   
   private
   def cache_district_and_state
     if self.zipcode_changed? || self.zip_four_changed?
       self.district_cache = self.my_district
       self.state_cache = self.my_state
     end
   end

end
