class Person < ActiveRecord::Base  
  
#  acts_as_solr :fields => [:party, {:with_party_percentage => :float}, {:abstains_percentage => :float}, {:against_party_percentage => :float}], 
#               :facets => [:party]
  
  has_many :committees, :through => :committee_people
  has_many :committee_people, :conditions => [ "committees_people.session = ?", DEFAULT_CONGRESS ]
  has_many :bills, :foreign_key => :sponsor_id, :conditions => [ "bills.session = ?", DEFAULT_CONGRESS ], :include => [ :bill_titles, :actions ], :order => 'bills.introduced DESC'
  has_many :bill_cosponsors
  has_many :bills_cosponsored, :class_name => 'Bill', :through => :bill_cosponsors, :source => :bill, :conditions => [ "bills.session = ?", DEFAULT_CONGRESS ], :order => 'bills.introduced DESC'
  has_many :roles, :order => 'roles.startdate DESC'
  has_many :roll_call_votes, :include => :roll_call, :order => 'roll_calls.date DESC'
  
  has_many :unabstained_roll_calls, :class_name => "RollCall", :through => :roll_call_votes, 
                                    :source => :roll_call, :include => [:bill],
                                    :conditions => ["roll_call_votes.vote != '0' AND bills.session = ?", DEFAULT_CONGRESS]
  
  has_many :abstained_roll_calls, :class_name => "RollCall", :through => :roll_call_votes, 
                                  :source => :roll_call, :include => [:bill],
                                  :conditions => ["vote = '0' AND bills.session = ?", DEFAULT_CONGRESS]

  has_many :party_votes, :class_name => "RollCall", :through => :roll_call_votes, :source => :roll_call,
              :include => [:bill], 
              :conditions => '((roll_calls.#{party == "Democrat" ? "democratic_position" : "republican_position"} = \'t\' 
                              AND vote = \'+\')
                              OR (roll_calls.#{party == "Democrat" ? "democratic_position" : "republican_position"} = \'f\' 
                              AND vote = \'-\')) AND bills.session = #{DEFAULT_CONGRESS}'

  has_many :person_approvals

  named_scope :republican, :conditions => {:party => "Republican"}
  named_scope :democrat, :conditions => {:party => "Democrat"}
  named_scope :independent, :conditions => ["party != 'Republican' AND party != 'Democrat'"]
  
  named_scope :sen, :joins => :roles, :select => "people.*", :conditions => ["roles.person_id = people.id AND roles.role_type='sen' AND roles.enddate > ?", Date.today]
  named_scope :rep, :joins => :roles, :select => "people.*", :conditions => ["roles.person_id = people.id AND roles.role_type='rep' AND roles.enddate > ?", Date.today]


  has_many :news, :as => :commentariable, :class_name => 'Commentary', :order => 'commentaries.date DESC', :conditions => "commentaries.is_ok = 't' AND commentaries.is_news='t'"
  has_many :idsorted_news, :as => :commentariable, :class_name => 'Commentary', :order => 'commentaries.id DESC', :conditions => "commentaries.is_ok = 't' AND commentaries.is_news='t'"
  has_many :idsorted_blogs, :as => :commentariable, :class_name => 'Commentary', :order => 'commentaries.id DESC', :conditions => "commentaries.is_ok = 't' AND commentaries.is_news='f'"

  has_many :recent_news, :as => :commentariable, :class_name => 'Commentary', :order => 'commentaries.date DESC', :conditions => "commentaries.is_ok = 't' AND commentaries.is_news='t'", :limit => 10
  has_many :blogs, :as => :commentariable, :class_name => 'Commentary', :order => 'commentaries.date DESC', :conditions => "commentaries.is_ok = 't' AND commentaries.is_news='f'"
  has_many :recent_blogs, :as => :commentariable, :class_name => 'Commentary', :order => 'commentaries.date DESC', :conditions => "commentaries.is_ok = 't' AND commentaries.is_news='f'", :limit => 10

  has_many :cycle_contributions, :class_name => 'PersonCycleContribution', :order => 'people_cycle_contributions.cycle DESC'

  has_many :person_sectors
  has_many :sectors, :through => :person_sectors, :select => 'sectors.*, people_sectors.total, people_sectors.cycle', :order => 'people_sectors.total DESC'
  has_many :committee_reports
  has_many :featured_people, :order => 'created_at DESC'

  has_many :comments, :as => :commentable
  has_many :page_views, :as => :viewable
  has_many :bookmarks, :as => :bookmarkable

  has_many :videos, :order => "videos.video_date DESC, videos.id"
  
#  acts_as_bookmarkable

  has_one :person_stats, :dependent => :destroy
  
  has_one :wiki_link, :as => "wikiable"

  before_update :set_party
  
  set_primary_key :id #From Benjamin: Why would we need this?

  alias :blog :blogs
  
  @@DISPLAY_OBJECT_NAME = 'Person'
  
  @@NONVOTING_TERRITORIES = [ 'AS', 'DC', 'GU', 'PR', 'VI']
  
  def display_object_name
    @@DISPLAY_OBJECT_NAME
  end
  
  def atom_id_as_feed
    "tag:opencongress.org,2007:/person_feed/#{id}"
  end

  def atom_id_as_entry
    "tag:opencongress.org,2007:/person/#{id}"
  end

  def oc_approval_rating
    self.person_approvals.average(:rating).round * 10
  end
  
  def oc_user_comments
    self.comments.count
  end
  
  def oc_users_tracking
    self.bookmarks.count
  end
  
  def to_api_xml
    self.to_xml(:include => [:recent_news, :recent_blogs, :oc_approval_rating])
  end

  def with_party
    self.party_votes.count
  end
  
  def against_party
    self.unabstained_roll_calls.count - self.party_votes.count
  end
  
  def against_party_percentage
    if self.unabstained_roll_calls.count > 0
      return self.against_party.to_f / self.unabstained_roll_calls.count.to_f * 100 if self.unabstained_roll_calls.count > 0
    else
      return 0.0
    end
  end  
  
  def with_party_percentage
    if self.unabstained_roll_calls.count > 0
      return self.party_votes.count.to_f / self.unabstained_roll_calls.count.to_f * 100 if self.unabstained_roll_calls.count > 0
    else
      return 0.0
    end
  end
  
  def abstains_percentage
    if ( self.unabstained_roll_calls.count + self.abstained_roll_calls.count ) > 0
      self.abstained_roll_calls.count.to_f / ( self.unabstained_roll_calls.count.to_f + self.abstained_roll_calls.count.to_f )  * 100
    else
      return 0.0
    end
  end

  def self.custom_index_rebuild
    Person.rebuild_solr_index(30) do |person, options| 
       person.find(:all, options.merge({:joins => :roles, :select => "people.*", :conditions => ["roles.person_id = people.id AND roles.role_type='sen' AND roles.enddate > ?", Date.today]})) 
    end
    Person.rebuild_solr_index(30) do |person, options| 
       person.find(:all, options.merge({:joins => :roles, :select => "people.*", :conditions => ["roles.person_id = people.id AND roles.role_type='rep' AND roles.enddate > ?", Date.today]})) 
    end  
  end

  # returns the battle royale index
  def place_in_battle_royale_100
    b = Person.find_all_by_most_tracked_for_range(nil, {:limit => 100, :offset => 0, :person_type => self.title})
    b.rindex(self)
  end

  def br_page
    rindex = self.place_in_battle_royale_100
    if rindex
      return  ((rindex.to_f + 1.0) / 20.0).ceil
    else
      return nil
    end
  end

  def br_link
    page = self.br_page
    action_link = "representatives" if self.title == "Rep."
    action_link = "senators" if self.title == "Sen."
    if page
      return {:controller => :battle_royale, :action => action_link, :page => page, :person => self.ident, :timeframe => "AllTime"}
    else
      return nil
    end
  end

  def to_light_xml(options = {})
    default_options = {:methods => [:oc_user_comments, :oc_users_tracking], :except => [:fti_names]}
    self.to_xml(default_options.merge(options))
  end

  def to_medium_xml(options = {})
    default_options = {:methods => [:oc_user_comments, :oc_users_tracking], :except => [:fti_names]}
    self.to_xml(default_options.merge(options))
  end

  def Person.random_commentary(person_id, type, limit = 1, since = DEFAULT_COUNT_TIME)
    p = Person.find_by_id(person_id)
    random_item = nil
    if p
      if type == "news"
        random_item = p.idsorted_news.find(:first)
      else
        random_item = p.idsorted_blogs.find(:first)
      end                     
    end   
    if random_item
      return [p,random_item]
    else
      return [nil,nil]
    end       
  end
  
  def Person.list_chamber(chamber, congress, order, limit = nil)
    def_count_days = DEFAULT_COUNT_TIME.to_i / 24 / 60 / 60
    lim = limit.nil? ? "" : "LIMIT #{limit}"
    
    beer = Person.find_by_sql(["SELECT people.*, 
       COALESCE(person_approvals.person_approval_avg, 0) as person_approval_average,
       COALESCE(bills_sponsored.sponsored_bills_count, 0) as sponsored_bills_count,
       COALESCE(total_rolls.tcalls, 0) as total_roll_call_votes,
       CASE WHEN people.party = 'Democrat' THEN COALESCE(party_votes_democrat.pcount, 0)
            WHEN people.party = 'Republican' THEN COALESCE(party_votes_republican.pcount, 0)
            ELSE 0
       END as party_roll_call_votes,
       COALESCE(most_viewed.view_count, 0) as view_count,
       COALESCE(blogs.blog_count, 0) as blog_count,
       COALESCE(news.news_count, 0) as news_count
    FROM people
    LEFT OUTER JOIN roles on roles.person_id=people.id    
    LEFT OUTER JOIN (select person_approvals.person_id as person_approval_id, 
                     count(person_approvals.id) as person_approval_count, 
                     avg(person_approvals.rating) as person_approval_avg 
                    FROM person_approvals
                    GROUP BY person_approval_id) person_approvals
      ON person_approval_id = people.id
      
    LEFT OUTER JOIN (select sponsor_id, count(id) as sponsored_bills_count
                    FROM bills
                    WHERE bills.session = #{congress}
                    GROUP BY sponsor_id) bills_sponsored
      ON bills_sponsored.sponsor_id = people.id
    LEFT OUTER JOIN (SELECT DISTINCT(roll_call_votes.person_id), count(DISTINCT roll_calls.id) AS tcalls 
                    FROM roll_calls
                    LEFT OUTER JOIN bills ON bills.id = roll_calls.bill_id 
                    INNER JOIN roll_call_votes ON roll_calls.id = roll_call_votes.roll_call_id 
                      WHERE roll_call_votes.vote != '0' AND bills.session = #{congress}
                      GROUP BY roll_call_votes.person_id) total_rolls
    		          ON total_rolls.person_id = people.id
    LEFT OUTER JOIN (SELECT DISTINCT(roll_call_votes.person_id), count(DISTINCT roll_calls.id) AS pcount 
                     FROM roll_calls 
                     LEFT OUTER JOIN bills ON bills.id = roll_calls.bill_id 
                     INNER JOIN roll_call_votes ON roll_calls.id = roll_call_votes.roll_call_id 
                     WHERE ((roll_calls.democratic_position = true AND vote = '+') OR (roll_calls.democratic_position = false AND vote = '-')) 
                     AND bills.session = #{congress}
                 GROUP BY roll_call_votes.person_id) party_votes_democrat
    	     ON party_votes_democrat.person_id = people.id
    	    LEFT OUTER JOIN (SELECT DISTINCT(roll_call_votes.person_id), count(DISTINCT roll_calls.id) AS pcount 
    	                     FROM roll_calls 
    	                     LEFT OUTER JOIN bills ON bills.id = roll_calls.bill_id 
    	                     INNER JOIN roll_call_votes ON roll_calls.id = roll_call_votes.roll_call_id 
    	                     WHERE ((roll_calls.republican_position = true AND vote = '+') OR (roll_calls.republican_position = false AND vote = '-')) 
    	                     AND bills.session = #{congress}
    		             GROUP BY roll_call_votes.person_id) party_votes_republican
    			     ON party_votes_republican.person_id = people.id
           LEFT OUTER JOIN (SELECT page_views.viewable_id,
                                          count(page_views.viewable_id) AS view_count
                                   FROM page_views 
                                   WHERE page_views.created_at > current_timestamp - interval '#{def_count_days} days' AND
                                         page_views.viewable_type = 'Person'
                                   GROUP BY page_views.viewable_id
                                   ORDER BY view_count DESC) most_viewed
                                  ON people.id=most_viewed.viewable_id
           LEFT OUTER JOIN (SELECT count(commentaries.id) as blog_count, commentaries.commentariable_id
                                   FROM commentaries 
                                   WHERE commentaries.date > current_timestamp - interval '#{def_count_days} days' AND
                                         commentaries.is_news = 'f' AND 
                                         commentaries.commentariable_type = 'Person'
                                   GROUP BY commentaries.commentariable_id
                                   ORDER BY blog_count DESC) blogs
                                  ON people.id=blogs.commentariable_id      
           LEFT OUTER JOIN (SELECT count(commentaries.id) as news_count, commentaries.commentariable_id
                                   FROM commentaries 
                                   WHERE commentaries.date > current_timestamp - interval '#{def_count_days} days' AND
                                         commentaries.commentariable_type = 'Person' AND commentaries.is_news = 't'
                                   GROUP BY commentaries.commentariable_id
                                   ORDER BY news_count DESC) news
                                  ON people.id=news.commentariable_id                                                                  			       
    WHERE roles.role_type = ? AND roles.startdate <= ? AND roles.enddate >= ? ORDER BY #{order} #{lim};", chamber, Date.today, Date.today])
  end

  def Person.rep_random_news(limit = 1, since = DEFAULT_COUNT_TIME)
    random_item = nil
    tries = 0
    until random_item != nil || tries == 3
      p = Person.rep.find(:first, :order => "random()")
      random_item = p.recent_news.find(:first, :conditions => ["commentaries.created_at > ?", Time.now - since], :order => "random()", :limit => limit) if p
      tries = tries + 1
    end
    if random_item
      return [p,random_item]
    else
      return []
    end
  end

  def Person.rep_random_blog(limit = 1, since = DEFAULT_COUNT_TIME)
    random_item = nil
    tries = 0
    until random_item != nil || tries == 3
      p = Person.rep.find(:first, :order => "random()")
      random_item = p.recent_blogs.find(:first, :conditions => ["commentaries.created_at > ?", Time.now - since], :order => "random()", :limit => limit) if p
      tries = tries + 1
    end
    if random_item
      return [p,random_item]
    else
      return []
    end
  end

  def Person.sen_random_news(limit = 1, since = DEFAULT_COUNT_TIME)
    random_item = nil
    tries = 0
    until random_item != nil || tries == 3
      p = Person.sen.find(:first, :order => "random()")
      random_item = p.recent_news.find(:first, :conditions => ["commentaries.created_at > ?", Time.now - since], :order => "random()", :limit => limit) if p
      tries = tries + 1
    end
    if random_item
      return [p,random_item]
    else
      return []
    end
  end

  def Person.sen_random_blog(limit = 1, since = DEFAULT_COUNT_TIME)
    random_item = nil
    tries = 0
    until random_item != nil || tries == 3
      p = Person.sen.find(:first, :order => "random()")
      random_item = p.recent_blogs.find(:first, :conditions => ["commentaries.created_at > ?", Time.now - since], :order => "random()", :limit => limit) if p
      tries = tries + 1
    end
    if random_item
      return [p,random_item]
    else
      return []
    end
  end

  def sponsored_bills_rank
    b = Bill.sponsor_count
    number = 0
    rank = 0
    out_of = 0
    case self.title
    when 'Sen.'  
      temp_rank = b.index(b.detect {|x| x[0].to_i == self.id})
      puts temp_rank
      if temp_rank 
        number = b.values_at(temp_rank).first.last
        rank = temp_rank + 1
      end
      out_of = 100
    when 'Rep.'
      temp_rank = b.index(b.detect {|x| x[0].to_i == self.id})
      if temp_rank
        number = b.values_at(temp_rank).first.last
        rank = temp_rank + 1
      end
      out_of = 440
    end
    return [number,rank,out_of]
  end

  def co_sponsored_bills_rank
    b = Bill.cosponsor_count
    number = 0    
    rank = 0
    out_of = 0
    case self.title
    when 'Sen.'  
      temp_rank = b.index(b.detect {|x| x[0].to_i == self.id})
      if temp_rank
        number = b.values_at(temp_rank).first.last
        rank = temp_rank + 1
      end
      out_of = 100
    when 'Rep.'
      temp_rank = b.index(b.detect {|x| x[0].to_i == self.id})
      if temp_rank
        number = b.values_at(temp_rank).first.last
        rank = temp_rank + 1
      end
      out_of = 440
    end
    return [number,rank,out_of]
  end
  
  def abstain_rank
    b = RollCallVote.abstain_count
    number = 0    
    rank = 0
    out_of = 0
    case self.title
    when 'Sen.'  
      temp_rank = b.index(b.detect {|x| x[0].to_i == self.id})
      if temp_rank
        number = b.values_at(temp_rank).first.last
        rank = temp_rank + 1
      end
      out_of = 100
    when 'Rep.'
      temp_rank = b.index(b.detect {|x| x[0].to_i == self.id})
      if temp_rank
        number = b.values_at(temp_rank).first.last
        rank = temp_rank + 1
      end
      out_of = 440
    end
    return [number,rank,out_of]
  end    

  def has_contact_webform?
    (!self.contact_webform.blank? && (self.contact_webform =~ /^http:\/\//)) ? true : false
  end
  
  def has_wiki_link?
    if self.wiki_url.blank?
      return false
    else
      return true
    end
  end

  def wiki_url
  
    link = ""
    
    unless self.wiki_link
      link = "#{WIKI_BASE_URL}/wiki/#{firstname}_#{lastname}"
    else
      link = "#{WIKI_BASE_URL}/wiki/#{self.wiki_link.name}"
    end
    
    return link

  end


  # Battle Royale
  def Person.find_all_by_most_tracked_for_range(range, options)
    range = 630720000 if range.nil?

    # this prevents sql injection
    possible_orders = ["bookmark_count_1 desc", "bookmark_count_1 asc", 
                       "p_approval_avg desc", "p_approval_avg asc", "p_approval_count desc", 
                       "p_approval_count asc", "total_comments asc", "total_comments desc"]
    order = options[:order] ||= "bookmark_count_1 desc"
    search = options[:search]

    if possible_orders.include?(order)
      limit = options[:limit] ||= 20
      offset = options[:offset] ||= 0
      person_type = options[:person_type] ||= "Sen."
      not_null_check = order.split(' ').first
      
      if search
           find_by_sql(["select people.*, rank(fti_names, ?, 1) as tsearch_rank, current_period.bookmark_count_1 as bookmark_count_1,
                       comments_total.total_comments as total_comments, papps.p_approval_count as p_approval_count,
                       papps.p_approval_avg as p_approval_avg,
                       previous_period.bookmark_count_2 as bookmark_count_2 
                       FROM people
                       INNER JOIN (select bookmarks.bookmarkable_id  as people_id_1, 
                                   count(bookmarks.bookmarkable_id) as bookmark_count_1 
                                   FROM bookmarks 
                                       WHERE created_at > ? AND 
                                             created_at <= ? 
                                   GROUP BY people_id_1) current_period 
                       ON people.id=current_period.people_id_1
                       LEFT OUTER JOIN (select comments.commentable_id as people_id_5, 
                                        count(comments.*) as total_comments 
                                    FROM comments 
                                        WHERE created_at > ? AND 
                                        comments.commentable_type = 'Person' 
                                    GROUP BY comments.commentable_id) comments_total 
                       ON people.id=comments_total.people_id_5 
                       LEFT OUTER JOIN (select bookmarks.bookmarkable_id as people_id_2, 
                                        count(bookmarks.bookmarkable_id) as bookmark_count_2 
                                        FROM bookmarks 
                                             WHERE created_at > ? AND 
                                                   created_at <= ? 
                                        GROUP BY people_id_2) previous_period 
                       ON people.id=previous_period.people_id_2
                       LEFT OUTER JOIN (select person_approvals.person_id as p_approval_id, 
                                        count(person_approvals.id) as p_approval_count, 
                                        avg(person_approvals.rating) as p_approval_avg 
                                       FROM person_approvals
                                           WHERE person_approvals.created_at > '#{range.seconds.ago.to_s(:db)}' 
                                       GROUP BY p_approval_id) papps 
                       ON p_approval_id = people.id
                       WHERE #{not_null_check} is not null AND people.title = '#{person_type}'
                       AND  people.fti_names @@ to_tsquery('english', ?)
                       ORDER BY #{order} LIMIT #{limit} OFFSET #{offset}", 
                       search, range.seconds.ago, Time.now, range.seconds.ago, (range*2).seconds.ago, range.seconds.ago, search])
                       
                       

       else
           find_by_sql(["select people.*, current_period.bookmark_count_1 as bookmark_count_1,
                       comments_total.total_comments as total_comments, papps.p_approval_count as p_approval_count,
                       papps.p_approval_avg as p_approval_avg,
                       previous_period.bookmark_count_2 as bookmark_count_2 
                       FROM people
                       INNER JOIN (select bookmarks.bookmarkable_id  as people_id_1, 
                                   count(bookmarks.bookmarkable_id) as bookmark_count_1 
                                   FROM bookmarks 
                                       WHERE created_at > ? AND 
                                             created_at <= ? 
                                   GROUP BY people_id_1) current_period 
                       ON people.id=current_period.people_id_1
                       LEFT OUTER JOIN (select comments.commentable_id as people_id_5, 
                                        count(comments.*) as total_comments 
                                    FROM comments 
                                        WHERE created_at > ? AND 
                                        comments.commentable_type = 'Person' 
                                    GROUP BY comments.commentable_id) comments_total 
                       ON people.id=comments_total.people_id_5 
                       LEFT OUTER JOIN (select bookmarks.bookmarkable_id as people_id_2, 
                                        count(bookmarks.bookmarkable_id) as bookmark_count_2 
                                        FROM bookmarks 
                                             WHERE created_at > ? AND 
                                                   created_at <= ? 
                                        GROUP BY people_id_2) previous_period 
                       ON people.id=previous_period.people_id_2
                       LEFT OUTER JOIN (select person_approvals.person_id as p_approval_id, 
                                        count(person_approvals.id) as p_approval_count, 
                                        avg(person_approvals.rating) as p_approval_avg 
                                       FROM person_approvals
                                           WHERE person_approvals.created_at > '#{range.seconds.ago.to_s(:db)}' 
                                       GROUP BY p_approval_id) papps 
                       ON p_approval_id = people.id
                       WHERE #{not_null_check} is not null AND people.title = '#{person_type}'
                       ORDER BY #{order} LIMIT #{limit} OFFSET #{offset}", 
                       range.seconds.ago, Time.now, range.seconds.ago, (range*2).seconds.ago, range.seconds.ago])
        end         
    else
      return []
    end
  end

  def Person.count_all_by_most_tracked_for_range(range, options)
    range = 630720000 if range.nil?

    # this prevents sql injection
    possible_orders = ["bookmark_count_1 desc", "bookmark_count_1 asc", 
                       "p_approval_avg desc", "p_approval_avg asc", "p_approval_count desc", 
                       "p_approval_count asc", "total_comments asc", "total_comments desc"]
    logger.info options.to_yaml
    order = options[:order] ||= "bookmark_count_1 desc"
    search = options[:search]

    if possible_orders.include?(order)
      limit = options[:limit] ||= 20
      offset = options[:offset] ||= 0
      person_type = options[:person_type] ||= "Sen."
      not_null_check = order.split(' ').first
      
      if search
           count_by_sql(["select count(people.*)
                       FROM people
                       INNER JOIN (select bookmarks.bookmarkable_id  as people_id_1, 
                                   count(bookmarks.bookmarkable_id) as bookmark_count_1 
                                   FROM bookmarks 
                                       WHERE created_at > ? AND 
                                             created_at <= ? 
                                   GROUP BY people_id_1) current_period 
                       ON people.id=current_period.people_id_1
                       LEFT OUTER JOIN (select comments.commentable_id as people_id_5, 
                                        count(comments.*) as total_comments 
                                    FROM comments 
                                        WHERE created_at > ? AND 
                                        comments.commentable_type = 'Person' 
                                    GROUP BY comments.commentable_id) comments_total 
                       ON people.id=comments_total.people_id_5 
                       LEFT OUTER JOIN (select bookmarks.bookmarkable_id as people_id_2, 
                                        count(bookmarks.bookmarkable_id) as bookmark_count_2 
                                        FROM bookmarks 
                                             WHERE created_at > ? AND 
                                                   created_at <= ? 
                                        GROUP BY people_id_2) previous_period 
                       ON people.id=previous_period.people_id_2
                       LEFT OUTER JOIN (select person_approvals.person_id as p_approval_id, 
                                        count(person_approvals.id) as p_approval_count, 
                                        avg(person_approvals.rating) as p_approval_avg 
                                       FROM person_approvals
                                           WHERE person_approvals.created_at > '#{range.seconds.ago.to_s(:db)}' 
                                       GROUP BY p_approval_id) papps 
                       ON p_approval_id = people.id
                       WHERE #{not_null_check} is not null AND people.title = '#{person_type}'
                       AND  people.fti_names @@ to_tsquery('english', ?)
                       LIMIT #{limit} OFFSET #{offset}", 
                       range.seconds.ago, Time.now, range.seconds.ago, (range*2).seconds.ago, range.seconds.ago, search])
                       
                       

       else
           count_by_sql(["select count(people.*)
                       FROM people
                       INNER JOIN (select bookmarks.bookmarkable_id  as people_id_1, 
                                   count(bookmarks.bookmarkable_id) as bookmark_count_1 
                                   FROM bookmarks 
                                       WHERE created_at > ? AND 
                                             created_at <= ? 
                                   GROUP BY people_id_1) current_period 
                       ON people.id=current_period.people_id_1
                       LEFT OUTER JOIN (select comments.commentable_id as people_id_5, 
                                        count(comments.*) as total_comments 
                                    FROM comments 
                                        WHERE created_at > ? AND 
                                        comments.commentable_type = 'Person' 
                                    GROUP BY comments.commentable_id) comments_total 
                       ON people.id=comments_total.people_id_5 
                       LEFT OUTER JOIN (select bookmarks.bookmarkable_id as people_id_2, 
                                        count(bookmarks.bookmarkable_id) as bookmark_count_2 
                                        FROM bookmarks 
                                             WHERE created_at > ? AND 
                                                   created_at <= ? 
                                        GROUP BY people_id_2) previous_period 
                       ON people.id=previous_period.people_id_2
                       LEFT OUTER JOIN (select person_approvals.person_id as p_approval_id, 
                                        count(person_approvals.id) as p_approval_count, 
                                        avg(person_approvals.rating) as p_approval_avg 
                                       FROM person_approvals
                                           WHERE person_approvals.created_at > '#{range.seconds.ago.to_s(:db)}' 
                                       GROUP BY p_approval_id) papps 
                       ON p_approval_id = people.id
                       WHERE #{not_null_check} is not null AND people.title = '#{person_type}'
                       LIMIT #{limit} OFFSET #{offset}", 
                       range.seconds.ago, Time.now, range.seconds.ago, (range*2).seconds.ago, range.seconds.ago])
        end         
    else
      return []
    end
  end

  def last_x_bills(limit = 2)
     self.bills.find(:all, :limit => limit)
     #[]
  end
  
  def recent_activity(since = nil)
    items = []
    items << bills.find(:all, :include => :bill_titles, :limit => 20).to_a
    items.concat(votes(20).to_a)
    
    items.flatten!
    items = items.select {|x| x.sort_date >= since} if since
    items.sort! { |x,y| y.sort_date <=> x.sort_date }
    items
  end
  
  def recent_activity_mini_list(since = nil)
    host = "dev.opencongress.org"
    host = "www.opencongress.org" if RAILS_ENV=="production"
    
    items = []
    self.recent_activity(since).each do |i|
      case i.class.name
      when 'Bill'
        items << {:sort_date => i.sort_date.to_date, :content => "Introduced Bill: #{i.title_typenumber_only} - #{i.title_official}", :link => {:host => host, :only_path => false, :controller => 'bill', :action => 'show', :id => i.ident}}
      when 'RollCallVote'
        if i.roll_call.bill
          items << {:sort_date => i.sort_date.to_date, :content => "Vote: '" + i.to_s + "' regarding " + i.roll_call.bill.title_typenumber_only, :link => {:host => host, :only_path => false, :controller => 'roll_call', :action => 'show', :id => i.roll_call}}
        else
          items << {:sort_date => i.sort_date.to_date, :content => "Vote: '" + i.to_s + "' on the question " + i.roll_call.question, :link => {:host => host, :only_path => false, :controller => 'roll_call', :action => 'show', :id => i.roll_call}}
        end
      end  
    end
    items.group_by{|x| x[:sort_date]}.to_a.sort{|a,b| b[0]<=>a[0]}
  end
  
  def Person.random(role, limit=3, congress=109)
    Person.find_by_sql ["SELECT * FROM (SELECT random(), people.* FROM people LEFT OUTER JOIN roles on roles.person_id=people.id WHERE roles.role_type = ? AND roles.startdate <= ? AND roles.enddate >= ? ORDER BY 1) as peeps LIMIT ?;", role, CONGRESS_START_DATES[congress], CONGRESS_START_DATES[congress], limit]
  end

  def Person.find_all_by_last_name_ci_and_state(name, state)
    Person.find(:all, 
                :include => :roles,
                :conditions => ["lower(lastname) = ? AND people.state = ?", name.downcase, state])
  end

  def Person.find_all_by_first_name_ci_and_last_name_ci_and_state(first, last, state)
    Person.find(:all, 
                :include => :roles,
                :conditions => ["lower(lastname) = ? AND (lower(firstname) = ? OR lower(nickname) = ?) AND people.state = ?", last.downcase, first.downcase, first.downcase, state])
    
  end

  def Person.find_by_first_name_ci_and_last_name_ci(first,last)
    Person.find(:all, 
                :include => :roles,
                :conditions => ["lower(lastname) = ? AND (lower(firstname) = ? OR lower(nickname) = ?)", last.downcase, first.downcase, first.downcase])
  end

  def Person.find_all_by_last_name_ci(name)
    Person.find(:all, 
                :include => :roles,
                :conditions => ["lower(lastname) = ?", name.downcase])
  end

  def Person.find_current_senators_by_state(state)
    Person.find_all_by_state_and_title(state, 'Sen.')
  end

  def Person.find_current_congresspeople_by_address_and_zipcode(address, zipcode)
    # use watchdog
    response = nil
    begin
      http = Net::HTTP.new('watchdog.net')
      http.start do |http|
        request = Net::HTTP::Get.new("/us/?address=#{URI.escape(address)}&zip=#{URI.escape(zipcode)}", {"User-Agent" => DEFAULT_USERAGENT})
        response = http.request(request)
      end
    rescue Exception => e
      logger.warn("Error looking up address on watchdog!: #{e}")
      return nil
    end
    
    return nil if response.nil?
    
    if response.kind_of?(Net::HTTPRedirection)
      # if we're redirected, that's good
      md = /(\w\w)-(\d\d)/.match(response['location'])
      if md
        state = md.captures[0].upcase
        district = md.captures[1].to_i.to_s
        rep = find(:first, 
                   :conditions => ["state = ? AND district = ? AND title = ?", state, district.to_i.to_s, 'Rep.'])
                    
        sens = find_current_senators_by_state(state)
        return [sens, [rep]]
      else
        return nil
      end
    else
      return nil
    end  
    
    return nil
  end
  
  def Person.find_current_representative_by_state_and_district(state, district)
    Person.find(:first, 
                :include => [:roles],
                :conditions => ["people.state = ? AND people.district = '?' AND roles.role_type='rep' AND roles.enddate > ?", state, district, Date.today])
  end
  
  def Person.find_current_congresspeople_by_zipcode(zip5, zip4)
    zd = ZipcodeDistrict.zip_lookup(zip5, zip4)
    
    return nil if zd.empty?
    
    # get the state
    state = zd.first.state
    
    senators = self.find_current_senators_by_state(state)
    
    reps = []
    zd.each do |d|
      rep = Person.find_current_representative_by_state_and_district(state, d.district)
      reps << rep if rep
    end
    
    [senators, reps]
  end
  
  def Person.find_current_senators_by_state(state)
      Person.find(:all,
                  :include => [:roles],
                  :conditions => ["people.state = ? AND roles.enddate > ? AND roles.role_type='sen'", state, Date.today])
  end

  def Person.find_current_representatives_by_state_and_district(state, district)
      Person.find(:all,
                  :conditions => ["title='Rep.' AND state = ? AND district in (?)", state, district])
  end


  # return bill actions since last X
  def self.find_user_data_for_tracked_person(person, current_user)
     time_since = current_user.previous_login_date || 20.days.ago
     time_since = 200.days.ago if RAILS_ENV == "development"
     find_by_id(person.id,
                    :select => "people.*, 
                                (select count(roll_call_votes.id) FROM roll_call_votes
                                     INNER JOIN (select roll_calls.id, roll_calls.date FROM roll_calls WHERE roll_calls.date > '#{time_since.to_s(:db)}') rcs 
                                         ON rcs.id = roll_call_votes.roll_call_id
                                     WHERE person_id = #{person.id} ) as votes_count,
                                (select count(commentaries.id) FROM commentaries 
                                     WHERE commentaries.commentariable_id = #{person.id},
                                       AND commentariable_type = 'Person'
                                       AND commentaries.is_ok = 't' 
                                       AND commentaries.is_news='f'
                                       AND commentaries.date > '#{time_since.to_s(:db)}'  ) as blog_count,
                                (select count(commentaries.id) FROM commentaries 
                                    WHERE commentaries.commentariable_id = #{person.id},
                                      AND commentariable_type = 'Person'
                                      AND commentaries.is_ok = 't' 
                                      AND commentaries.is_news='t'
                                      AND commentaries.date > '#{time_since.to_s(:db)}' ) as newss_count,
                                (select count(comments.id) FROM comments
                                     WHERE comments.created_at > '#{time_since.to_s(:db)}'
                                       AND comments.commentable_type='Person'
                                       AND comments.commentable_id = #{person.id}) as comment_count")
  end

  # return bill actions since last X
  def self.find_changes_since_for_senators_tracked(current_user)
     time_since = current_user.previous_login_date || 20.days.ago
     time_since = 200.days.ago if RAILS_ENV == "development"
     ids = current_user.senator_bookmarks.collect{|p| p.bookmarkable_id}
     return [] if ids.empty?
     find_by_sql("select people.*, total_actions.action_count as votes_count,
                                total_blogs.blog_count as blogss_count, total_news.news_count as newss_count,
                                total_comments.comments_count as commentss_count from people 
                                LEFT OUTER JOIN (select count(roll_call_votes.id) as action_count, 
                                    roll_call_votes.person_id as person_id_1 FROM roll_call_votes
                                    INNER JOIN ( select roll_calls.id, roll_calls.date FROM roll_calls WHERE roll_calls.date > '#{time_since.to_s(:db)}') rcs
                                    ON rcs.id = roll_call_votes.roll_call_id
                                    WHERE roll_call_votes.person_id in (#{ids.join(",")})
                                    group by person_id_1) total_actions ON 
                                    total_actions.person_id_1 = people.id 
                                LEFT OUTER JOIN (select count(commentaries.id) as blog_count,
                                    commentaries.commentariable_id as person_id_2 FROM commentaries WHERE
                                    commentaries.commentariable_id IN (#{ids.join(",")}) AND
                                    commentaries.commentariable_type='Person' AND
                                    commentaries.is_ok = 't' AND commentaries.is_news='f' AND
                                    commentaries.date > '#{time_since.to_s(:db)}'
                                    group by commentaries.commentariable_id) 
                                    total_blogs ON total_blogs.person_id_2 = people.id 
                                LEFT OUTER JOIN (select count(commentaries.id) as news_count,
                                    commentaries.commentariable_id as person_id_3 FROM commentaries WHERE
                                    commentaries.commentariable_id IN (#{ids.join(",")}) AND
                                    commentaries.commentariable_type='Person' AND
                                    commentaries.is_ok = 't' AND commentaries.is_news='t' AND
                                    commentaries.date > '#{time_since.to_s(:db)}'
                                    group by commentaries.commentariable_id)
                                    total_news ON total_news.person_id_3 = people.id 
                                LEFT OUTER JOIN (select count(comments.id) as comments_count,
                                    comments.commentable_id as person_id_4 FROM comments WHERE
                                    comments.created_at > '#{time_since.to_s(:db)}' AND
                                    comments.commentable_id in (#{ids.join(",")}) AND
                                    comments.commentable_type = 'Bill' GROUP BY comments.commentable_id)
                                    total_comments ON total_comments.person_id_4 = people.id where people.id IN (#{ids.join(",")})")
  end
  
  # return bill actions since last X
  def self.find_changes_since_for_representatives_tracked(current_user)
     time_since = current_user.previous_login_date || 20.days.ago
     time_since = 200.days.ago if RAILS_ENV == "development"
     ids = current_user.representative_bookmarks.collect{|p| p.bookmarkable_id}
     return [] if ids.empty?
     find_by_sql("select people.*, total_actions.action_count as votes_count,
                                total_blogs.blog_count as blogss_count, total_news.news_count as newss_count,
                                total_comments.comments_count as commentss_count from people 
                                LEFT OUTER JOIN (select count(roll_call_votes.id) as action_count, 
                                    roll_call_votes.person_id as person_id_1 FROM roll_call_votes
                                    INNER JOIN ( select roll_calls.id, roll_calls.date FROM roll_calls WHERE roll_calls.date > '#{time_since.to_s(:db)}') rcs
                                    ON rcs.id = roll_call_votes.roll_call_id
                                    WHERE roll_call_votes.person_id in (#{ids.join(",")})
                                    group by person_id_1) total_actions ON 
                                    total_actions.person_id_1 = people.id 
                                LEFT OUTER JOIN (select count(commentaries.id) as blog_count,
                                    commentaries.commentariable_id as person_id_2 FROM commentaries WHERE
                                    commentaries.commentariable_id IN (#{ids.join(",")}) AND
                                    commentaries.commentariable_type='Person' AND
                                    commentaries.is_ok = 't' AND commentaries.is_news='f'  AND
                                    commentaries.date > '#{time_since.to_s(:db)}' 
                                    group by commentaries.commentariable_id) 
                                    total_blogs ON total_blogs.person_id_2 = people.id 
                                LEFT OUTER JOIN (select count(commentaries.id) as news_count,
                                    commentaries.commentariable_id as person_id_3 FROM commentaries WHERE
                                    commentaries.commentariable_id IN (#{ids.join(",")}) AND
                                    commentaries.commentariable_type='Person' AND
                                    commentaries.is_ok = 't' AND commentaries.is_news='t'  AND
                                    commentaries.date > '#{time_since.to_s(:db)}' 
                                    group by commentaries.commentariable_id)
                                    total_news ON total_news.person_id_3 = people.id 
                                LEFT OUTER JOIN (select count(comments.id) as comments_count,
                                    comments.commentable_id as person_id_4 FROM comments WHERE
                                    comments.created_at > '#{time_since.to_s(:db)}' AND
                                    comments.commentable_id in (#{ids.join(",")}) AND
                                    comments.commentable_type = 'Bill' GROUP BY comments.commentable_id)
                                    total_comments ON total_comments.person_id_4 = people.id where people.id IN (#{ids.join(",")})")
  end  

  # Returns the number of people tracking this bill, as well as suggestions of what other people
  # tracking this bill are also tracking.
  def tracking_suggestions

    facet_results_hsh = {:my_people_tracked_facet => [], :my_issues_tracked_facet => [], :my_bills_tracked_facet => []}
    my_trackers = 0

    users = User.find_by_solr('placeholder:placeholder', :facets => {:fields => [:my_people_tracked, :my_issues_tracked, :my_bills_tracked], :browse => ["my_people_tracked:#{self.id}"], :limit => 6, :zeros => false, :sort =>  true}, :limit => 1)
    facets = users.facets

    facet_results_ff = facets['facet_fields']
    if facet_results_ff && facet_results_ff != []
      
      facet_results_ff.each do |fkey, fvalue|
        facet_results = facet_results_ff[fkey]
      
        #solr running through acts as returns as a Hash, or an array if running through tomcat...hence this stuffs
        facet_results_temp_hash = Hash[*facet_results] unless facet_results.class.to_s == "Hash"
        facet_results_temp_hash = facet_results if facet_results.class.to_s == "Hash"

        facet_results_temp_hash.each do |key,value|
          if key == self.id.to_s && fkey == "my_people_tracked_facet"
            my_trackers = value
          else
            unless facet_results_hsh[fkey.to_sym].length == 5
              object = Person.find_by_id(key) if fkey == "my_people_tracked_facet"
              object = Subject.find_by_id(key) if fkey == "my_issues_tracked_facet"
              object = Bill.find_by_ident(key) if fkey == "my_bills_tracked_facet"
              facet_results_hsh[fkey.to_sym] << {:object => object, :trackers => value}
            end
          end
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
  
      return [my_trackers, facet_results_hsh]
    else
      return [my_trackers,{}]
    end
  end

  def support_suggestions
    primary = "my_approved_reps_facet" if self.title == "Rep."
    primary = "my_approved_sens_facet" if self.title == "Sen."
        
    return [0,{}] if self.title.blank?
    
    users = User.find_by_solr('placeholder:placeholder', :facets => {:fields => [:my_bills_supported, :my_approved_reps, :my_approved_sens, :my_disapproved_reps, :my_disapproved_sens, :my_bills_opposed], 
                                                      :browse => ["#{primary.gsub('_facet', '')}:#{self.id}"], 
                                                      :limit => 6, :zeros => false, :sort =>  true}, :limit => 1)
                                                      
    return parse_facets(users.facets, primary, ["my_approved_reps_facet","my_approved_sens_facet","my_disapproved_reps_facet","my_disapproved_sens_facet",
                                                                   "my_bills_supported_facet", "my_bills_opposed_facet"])
    
  end
  
  def oppose_suggestions
    primary = "my_disapproved_reps_facet" if self.roles.first.role_type == "rep"
    primary = "my_disapproved_sens_facet" if self.roles.first.role_type == "sen"
 
    return [0,{}] if self.title.blank?
                
    users = User.find_by_solr('placeholder:placeholder', :facets => {:fields => [:my_bills_supported, :my_approved_reps, :my_approved_sens, :my_disapproved_reps, :my_disapproved_sens, :my_bills_opposed], 
                                                      :browse => ["#{primary.gsub('_facet', '')}:#{self.id}"], 
                                                      :limit => 6, :zeros => false, :sort =>  true}, :limit => 1)
                                                      
    return parse_facets(users.facets, primary, ["my_approved_reps_facet","my_approved_sens_facet","my_disapproved_reps_facet","my_disapproved_sens_facet",
                                                                 "my_bills_supported_facet", "my_bills_opposed_facet"])
        
  end

  def consecutive_years
    chamber_roles = self.roles.find_all_by_role_type(self.roles.first.role_type, :order => "enddate desc")
    number_terms = chamber_roles.length

    total = 0
    (0..number_terms - 1).each do |t|
      if t != (number_terms - 1) && t != 0
        if chamber_roles[t].startdate - 1.day == chamber_roles[t+1].enddate
          total += ( chamber_roles[t-1].startdate.year - chamber_roles[t].startdate.year )
        else
          total += (chamber_roles[t-1].startdate.year - chamber_roles[t].startdate.year )
          break
        end
      elsif t == 0 && t != (number_terms - 1)
        if chamber_roles[t].startdate - 1.day == chamber_roles[t+1].enddate
          total += ( Date.today.year - chamber_roles[t].startdate.year )
        else
          total += (Date.today.year - chamber_roles[t].startdate.year )
          break
        end
      elsif t == 0 && t -= (number_terms - 1)
        total += Date.today.year - (chamber_roles[0]).startdate.year
      else       
        total += (chamber_roles[t-1].startdate.year - chamber_roles[t].startdate.year )
      end         
    end
    total
  end

  def parse_facets(facets, primary_facet, selected_facets)
    my_trackers = 0
    facet_results_hsh = {}
    selected_facets.each do |s|
      facet_results_hsh[s.to_sym] = []
    end
    facet_results_ff = facets['facet_fields']

    if facet_results_ff && facet_results_ff != []
      
      facet_results_ff.each do |fkey, fvalue|
        facet_results = facet_results_ff[fkey]
        #solr running through acts as returns as a Hash, or an array if running through tomcat...hence this stuffs
        facet_results_temp_hash = Hash[*facet_results] unless facet_results.class.to_s == "Hash"
        facet_results_temp_hash = facet_results if facet_results.class.to_s == "Hash"

        facet_results_temp_hash.each do |key,value|
          if key == self.id.to_s && fkey == primary_facet
            my_trackers = value
          else
            unless facet_results_hsh[fkey.to_sym].length == 5
              object = Bill.find_by_id(key) if fkey =~ /my_bills/
              object = Person.find_by_id(key) if object.nil?
              facet_results_hsh[fkey.to_sym] << {:object => object, :trackers => value}
            end
          end
        end
      end      
    else
      return [my_trackers,{}]
    end
 
    unless facet_results_hsh.empty?
      #sort the hashes
      selected_facets.each do |s|
        facet_results_hsh[s.to_sym].sort!{|a,b| b[:trackers]<=>a[:trackers] }
      end
  
      return [my_trackers, facet_results_hsh]
    else
      return [my_trackers,{}]
    end    
  end
  
  def Person.find_by_most_commentary(type = 'news', person_type = 'rep', num = 5, since = DEFAULT_COUNT_TIME)
    title = (person_type == 'rep') ? 'Rep.' : 'Sen.'
    is_news = (type == "news") ? true : false
    
    Person.find_by_sql(["SELECT people.*, top_people.article_count AS article_count FROM people
                       INNER JOIN
                       (SELECT commentaries.commentariable_id, count(commentaries.commentariable_id) AS article_count
                        FROM commentaries 
                        WHERE commentaries.commentariable_type='Person' AND
                              commentaries.date > ? AND
                              commentaries.is_news=? AND
                              commentaries.is_ok='t'
                        GROUP BY commentaries.commentariable_id
                        ORDER BY article_count DESC) top_people
                       ON people.id=top_people.commentariable_id
                       WHERE people.title = ?
                       ORDER BY article_count DESC
                       LIMIT ?", 
                      since.ago, is_news, title, num])
  end
  
  def Person.top20_commentary(type = 'news', person_type = 'rep')
    people = Person.find_by_most_commentary(type, person_type, num = 20)
    
    date_method = :"entered_top_#{type}"
    (people.select {|p| p.stats.send(date_method).nil? }).each do |pv|
      pv.stats.write_attribute(date_method, Time.now)
      pv.save
    end
    
    (people.sort { |p1, p2| p2.stats.send(date_method) <=> p1.stats.send(date_method) })
  end
  
  def commentary_count(type = 'news', since = DEFAULT_COUNT_TIME)
    return @attributes['article_count'] if @attributes['article_count']
    
    if type == 'news'
      news.find(:all, :conditions => [ "commentaries.date > ?", since.ago]).size
    else
      blogs.find(:all, :conditions => [ "commentaries.date > ?", since.ago]).size
    end
  end
  
  def Person.representatives(congress = DEFAULT_CONGRESS, order_by = 'name')
    Person.find_by_role_type('rep', congress, order_by)
  end
  
  def Person.voting_representatives
    Person.find(:all,
                :include => :roles,
                :conditions => [ "roles.role_type=? AND roles.enddate > ? AND roles.state NOT IN (?)",
                                 'rep',  Date.today, @@NONVOTING_TERRITORIES ], 
                :order => 'people.lastname')
  end

  def Person.senators(congress = DEFAULT_CONGRESS, order_by = 'name')
    Person.find_by_role_type('sen', congress, order_by)
  end

  def Person.find_by_role_type(role_type, congress, order_by)
    case order_by
    when 'state'
      order = "people.state, people.district"
    else
      order = "people.lastname"
    end
    
    Person.find(:all,
                :include => :roles,
                :conditions => [ "roles.role_type=? AND roles.enddate > ? ",
                                 role_type,  Date.today ], 
                :order => order)
  end
  
  def Person.all_sitting
    self.senators.concat(self.representatives)
  end
  
  def Person.all_voting
    self.senators.concat(self.voting_representatives)
  end
  
  def Person.top20_viewed(person_type = nil)
    case person_type 
    when 'sen'
      people = PageView.popular('Person', DEFAULT_COUNT_TIME, 540).select{|p| p.title == 'Rep.'}[0..20]
    when 'rep'
      people = PageView.popular('Person', DEFAULT_COUNT_TIME, 540).select{|p| p.title == 'Rep.'}[0..20]
    else
      people = PageView.popular('Person')
    end
    
    (people.select {|p| p.stats.entered_top_viewed.nil? }).each do |pv|
      pv.stats.entered_top_viewed = Time.now
      pv.save
    end
    
    if person_type
      case person_type
      when 'sen'
        people = people.select { |p| p.senator? }
      when 'rep'
        people = people.select { |p| p.representative? }
      end
    end
    
    (people.sort { |p1, p2| p2.stats.entered_top_viewed <=> p1.stats.entered_top_viewed })
  end
  
  def views(seconds = 0)
    # if the view_count is part of this instance's @attributes use that because it came from
    # the query and will make sense in the context of the page; otherwise, count
    return @attributes['view_count'] if @attributes['view_count']
    
    if seconds <= 0
      page_views_count
    else
      page_views.count(:conditions => ["created_at > ?", seconds.ago])
    end
  end
  
  def representative_for_congress?(congress = DEFAULT_CONGRESS )
    #may be able to simplify this as >= 400000
    not (roles.select { |r| r.role_type == 'rep' && r.startdate <= DateTime.parse(CONGRESS_START_DATES[congress]) && r.enddate >= DateTime.parse(CONGRESS_START_DATES[congress])  }.empty?)
  end

  def representative?
    not (roles.select { |r| r.role_type == 'rep' && r.startdate <= Date.today && r.enddate >= Date.today  }.empty?)    
  end
  
  def votes?
    not @@NONVOTING_TERRITORIES.include?(state)
  end

  def senator_for_congress? (congress = DEFAULT_CONGRESS)
    #may be able to simplify this as < 400000
    not (roles.select { |r| r.role_type == 'sen' && r.startdate <= DateTime.parse(CONGRESS_START_DATES[congress]) && r.enddate >= DateTime.parse(CONGRESS_START_DATES[congress])  }.empty?)
  end
  
  def senator?
    not (roles.select { |r| r.role_type == 'sen' && r.startdate <= Date.today && r.enddate >= Date.today  }.empty?)    
  end

  def congress? (congress = DEFAULT_CONGRESS)
    not (roles.select { |r| r.startdate <= DateTime.parse(CONGRESS_START_DATES[congress]) && r.enddate >= DateTime.parse(CONGRESS_START_DATES[congress])  }.empty?)
  end

  def belongs_to_major_party?
    ((party == 'Democrat') || (party == 'Republican'))
  end
  
  def party_and_state
    self.party.blank? ? "#{self.state}" : "#{self.party[0,1]}-#{self.state}"
  end
  
  def opposing_party
    if belongs_to_major_party?
      if party == 'Democrat'
        return 'Republican'
      else
        return 'Democrat'
      end
    else
      "N/A"
    end
  end
  def select_list_name
    "#{lastname}, #{firstname} (#{party_and_state})"
  end
  def short_name
    "#{title} " + lastname
  end
  def full_name
    "#{firstname} #{lastname}"
  end
  def title_full_name
		"#{title} " + full_name
	end
	
	def title_common
	  return 'Senator' if senator? 
	  return 'Rep.' if representative?
	  return ''
	end
	
	def title_long
	  case self.title
	    when 'Sen.'
	      'Senator'
	    when 'Rep.'
	      'Representative'
	  end
	end
	
	def title_for_share
	  name
	end
	
	def title_full_name_party_state
	  title_full_name + " " + party_and_state
	end

  def popular_name
    "#{sunlight_nickname || nickname || firstname} #{lastname}"
  end
  
  def to_param
    if unaccented_name
      "#{id}_#{unaccented_name.gsub(/[^A-Za-z]+/i, '_').gsub(/\s/, '_')}"
    else
      "#{id}_#{popular_name.gsub(/[^A-Za-z]+/i, '_').gsub(/\s/, '_')}"
    end
  end

  def ident
    "#{id}_#{firstname.downcase}_#{lastname.downcase}"
  end
	def rep_info
	foo = /(\[.*\])/.match(name)
	"#{foo.captures}"
	end
  def roles_sorted
    roles.sort { |r1, r2| r2.startdate <=> r1.startdate }
  end
  
  def consecutive_roles
    current_role = roles.first 
    
    roles.select {|r| r.role_type = current_role.role_type }
  end
  
  def votes_together_list
    Person.find_by_sql(["SELECT * FROM oc_votes_together(?, ?) 
                         AS (v_id integer, v_count bigint) 
                         LEFT OUTER JOIN people ON v_id=people.id 
                         ORDER BY v_count DESC", self.id, CONGRESS_START_DATES[DEFAULT_CONGRESS]])
  end
  
  def votes_apart_list
    Person.find_by_sql(["SELECT * FROM oc_votes_apart(?, ?) 
                         AS (v_id integer, v_count bigint) 
                         LEFT OUTER JOIN people ON v_id=people.id 
                         ORDER BY v_count DESC", self.id, CONGRESS_START_DATES[DEFAULT_CONGRESS]])
  end
  
  def is_sitting?
    title.blank? ? false : true
  end
  
  def votes(num = -1)
    if num > 0
      roll_call_votes.find(:all, :limit => num)
    else
      roll_call_votes
    end
  end

  def roll_call_votes_for_congress(congress = DEFAULT_CONGRESS)
    self.roll_call_votes.find(:all, :conditions => [ "roll_calls.date > ?", CONGRESS_START_DATES[DEFAULT_CONGRESS]],
                              :include => { :roll_call => { :roll_call_votes => :person }})
  end
  
  def most_and_least_voting_similarities
    [self.votes_together_list, self.votes_apart_list]
  end

  def stats
    unless self.person_stats
      self.person_stats = PersonStats.new :person => self
    end
    
    self.person_stats
  end
  
  def sectors_for_cycle(cycle = CURRENT_OPENSECRETS_CYCLE)
    sectors.select { |s| s.cycle == cycle }
  end
  
  # Return an array of people with an email address, and an
  # array of those without  
  def self.email_lists(people)
    people.partition {|p| p.email }
  end

  def self.full_text_search(q, options = {}, find_options = {})
    current = options[:only_current] ? " AND (people.title='Rep.' OR people.title='Sen.')" : ""
    
    people = Person.paginate_by_sql(["SELECT people.*, rank(fti_names, ?, 1) as tsearch_rank FROM people 
                                 WHERE people.fti_names @@ to_tsquery('english', ?) #{current}
                                 ORDER BY people.lastname", q, q],
                                 :per_page => DEFAULT_SEARCH_PAGE_SIZE, :page => options[:page])
    people     
  end

  def users_tracking_from_state_count(state)
    User.count_by_solr("my_state:\"#{state}\"", :facets => {:browse => ["public_tracking:true", "my_state_f:\"#{state}\"", "my_people_tracked:#{self.id}"]})
  end
  
  def average_approval_from_state(state)
    ids = User.find_id_by_solr("my_state:\"#{state}\"", :facets => {:browse => ["my_state_f:\"#{state}\"", "my_people_tracked:#{self.id}"]}, :limit => 5000)
    rating = PersonApproval.average(:rating, :conditions => ["user_id in (?)", ids.results])
    if rating
      return (rating * 10.00).round
    else
      return nil
    end
  end
  
  def average_approval_state
    average_approval_from_state(self.state)    
  end

  def top_interest_groups(num = 10)
    CrpInterestGroup.find_by_sql(["SELECT * FROM crp_interest_groups INNER JOIN 
    (SELECT crp_interest_group_osid, SUM(crp_contrib_individual_to_candidate.amount) as contrib_total 
    FROM crp_contrib_individual_to_candidate
    WHERE cycle='2008' AND recipient_osid='#{osid}' GROUP BY crp_interest_group_osid)
     top_igs ON crp_interest_groups.osid=top_igs.crp_interest_group_osid
     ORDER BY top_igs.contrib_total DESC LIMIT ?", num])
  end
  
  def comments_from_state_count(state)
    ids = User.find_id_by_solr("my_state:\"#{state}\"", :facets => {:browse => ["my_state_f:\"#{state}\"", "my_people_tracked:#{self.id}"]}, :limit => 5000)
    comments_count = Comment.count(:id, :conditions => ["commentable_type = ? AND commentable_id = ? AND user_id in (?)", 'Person', self.id, ids.results])
    return comments_count
  end

  def actions_timeline
    rolls = roll_call_votes.find(:all, :include => [{:roll_call => :bill}], 
                                       :conditions => ["bills.session = ?", DEFAULT_CONGRESS - 1]
                                ).group_by{|a| a.roll_call.date.to_date}.reverse
    start_date = Time.parse("January 1st, #{RollCall.find(:first, :include => 
                                              [:bill], 
                                              :conditions => ["bills.session = ?", DEFAULT_CONGRESS - 1], 
                                              :order => ["roll_calls.date asc"]).date.year}")
    end_date = start_date + 2.years
    puts end_date.to_s
    days = (end_date - start_date) / 60 / 60 / 24
    puts days
#      t = 0
    dates_arr = []
    (0..days - 1).each do |d|
      this_date = start_date + d.days
      these_rolls = rolls.select {|p| p[0] == this_date.to_date}.collect {|g| g[1].flatten}.flatten
      dates_arr[d] = {:date => this_date, :rolls => these_rolls}
    end
    return dates_arr
  end

  # sunlight api test, dont use
  def contact_link
    begin
    require 'open-uri'
    require 'hpricot'
    api_url = "http://www.api.sunlightlabs.com/people.getDataCondition.php?BioGuide_ID=#{bioguideid}&output=xml"
    response = Hpricot.XML(open(api_url))
    entry = (response/:entity_id).first.inner_html
    api_person_url = "http://api.sunlightlabs.com/people.getDataItem.php?id=#{entry}&code=webform&output=xml"
    person_response = Hpricot.XML(open(api_person_url))
    webform = (person_response/:webform).first.inner_html
    return webform 
    catch Exception
      return false
    end
  end
  
  # expiring the cache
  def fragment_cache_key
    "person_#{id}"
  end
  
  def expire_govtrack_fragments
    fragments = []
    
    fragments << "#{fragment_cache_key}_header"
    
    FragmentCacheSweeper::expire_fragments(fragments)
  end

  def expire_opensecrets_fragments
    FragmentCacheSweeper::expire_fragments(["#{fragment_cache_key}_opensecrets"])
  end
  
  def expire_commentary_fragments(type)
    FragmentCacheSweeper::expire_commentary_fragments(self, type)
  end
  
  # the following isn't called on an instance but rather, static-ly (sp?)
  def self.expire_meta_commentary_fragments
    person_types = ['sen', 'rep']
    commentary_types = ['news', 'blog']
    fragments = []

    person_types.each do |pt|
      commentary_types.each do |ct|
        [7, 14, 30].each do |d|
          fragments << "person_meta_#{pt}_most_#{ct}_#{d.days}"
        end
      end
    end
    
    FragmentCacheSweeper::expire_fragments(fragments)
  end
  
  @@ABBREV_FOR_STATE = { "alabama" => "AL",
    "alaska" => "AK" ,
    "arizona" => "AZ" ,
    "arkansas" => "AR" ,
    "california" => "CA" ,
    "colorado" => "CO" ,
    "connecticut" => "CT" ,
    "delaware" => "DE" ,
    "district of columbia" => "DC" ,
    "florida" => "FL" ,
    "georgia" => "GA" ,
    "hawaii" => "HI" ,
    "idaho" => "ID" ,
    "illinois" => "IL" ,
    "indiana" => "IN" ,
    "iowa" => "IA" ,
    "kansas" => "KS" ,
    "kentucky" => "KY" ,
    "louisiana" => "LA" ,
    "maine" => "ME" ,
    "maryland" => "MD" ,
    "massachusetts" => "MA" ,
    "michigan" => "MI" ,
    "minnesota" => "MN" ,
    "mississippi" => "MS" ,
    "missouri" => "MO" ,
    "montana" => "MT" ,
    "nebraska" => "NE" ,
    "nevada" => "NV" ,
    "new hampshire" => "NH" ,
    "new jersey" => "NJ" ,
    "new mexico" => "NM" ,
    "new york" => "NY" ,
    "north carolina" => "NC" ,
    "north dakota" => "ND" ,
    "ohio" => "OH" ,
    "oklahoma" => "OK" ,
    "oregon" => "OR" ,
    "pennsylvania" => "PA" ,
    "rhode island" => "RI" ,
    "south carolina" => "SC" ,
    "south dakota" => "SD" ,
    "tennessee" => "TN" ,
    "texas" => "TX" ,
    "utah" => "UT" ,
    "vermont" => "VT" ,
    "virginia" => "VA" ,
    "washington" => "WA" ,
    "west virginia" => "WV" ,
    "wisconsin" => "WI" ,
    "wyoming" => "WY" }

  def Person.abbrev_for_state(name)
    @@ABBREV_FOR_STATE[name.downcase]
  end
  
  @@STATE_FOR_ABBREV = { 
    "AL" => "Alabama",
    "AK" => "Alaska" ,
    "AZ" => "Arizona",
    "AR" => "Arkansas",
    "AS" => "American Samoa",    
    "CA" => "California",
    "CO" => "Colorado",
    "CT" => "Connecticut",
    "DE" => "Delaware",
    "DC" => "District of Columbia",
    "FL" => "Florida",
    "GA" => "Georgia",
    "GU" => "Guam",
    "HI" => "Hawaii",
    "ID" => "Idaho",
    "IL" => "Illinois",
    "IN" => "Indiana",
    "IA" => "Iowa",
    "KS" => "Kansas",
    "KY" => "Kentucky",
    "LA" => "Louisiana",
    "ME" => "Maine",
    "MD" => "Maryland",
    "MA" => "Massachusetts",
    "MI" => "Michigan",
    "MN" => "Minnesota",
    "MS" => "Mississippi",
    "MO" => "Missouri",
    "MT" => "Montana",
    "NE" => "Nebraska",
    "NV" => "Nevada",
    "NH" => "New Hampshire",
    "NJ" => "New Jersey",
    "NM" => "New Mexico",
    "NY" => "New York",
    "NC" => "North Carolina",
    "ND" => "North Dakota",
    "OH" => "Ohio",
    "OK" => "Oklahoma",
    "OR" => "Oregon",
    "PA" => "Pennsylvania",
    "PR" => "Puerto Rico",
    "RI" => "Rhode Island",
    "SC" => "South Carolina",
    "SD" => "South Dakota",
    "TN" => "Tennessee",
    "TX" => "Texas",
    "UT" => "Utah",
    "VI" => "Virgin Islands",
    "VT" => "Vermont",
    "VA" => "Virginia",
    "WA" => "Washington",
    "WV" => "West Virginia",
    "WI" => "Wisconsin",
    "WY" => "Wyoming" }

    @@RESIDENT_FOR_ABBREV = {
    "AL" => "Alabamian", 		  
    "AK" => "Alaskan", 	      
    "AZ" => "Arizonan", 		  
    "AR" => "Arkansan", 		  
    "CA" => "Californian", 	  
    "CO" => "Coloradan",   
    "CT" => "Connecticuter", 	  
    "DE" => "Delawarean", 	      
    "FL" => "Floridian", 		  
    "GA" => "Georgian", 	      
    "HI" => "Hawaiian", 		  
    "ID" => "Idahoan", 	      
    "IL" => "Illinoisan", 	      
    "IN" => "Indianian", 		  
    "IA" => "Iowan", 	          
    "KS" => "Kansan", 	          
    "KY" => "Kentuckian", 	      
    "LA" => "Louisianian", 	  
    "ME" => "Mainer", 			  
    "MD" => "Marylander", 	      
    "MA" => "Massachusettsan",   
    "MI" => "Michiganian", 	  
    "MN" => "Minnesotan", 	      
    "MS" => "Mississippian", 	  
    "MO" => "Missourian", 	      
    "MT" => "Montanan", 	      
    "NE" => "Nebraskan", 	      
    "NV" => "Nevadan", 		  
    "NH" => "New Hampshirite",   
    "NJ" => "New Jerseyan",   	  
    "NM" => "New Mexican", 	  
    "NY" => "New Yorker", 	      
    "NC" => "North Carolinian",  
    "ND" => "North Dakotan", 	  
    "OH" => "Ohioan", 	          
    "OK" => "Oklahoman", 		  
    "OR" => "Oregonian", 	      
    "PA" => "Pennsylvanian", 	  
    "RI" => "Rhode Islander", 	  
    "SC" => "South Carolinian",  
    "SD" => "South Dakotan", 	  
    "TN" => "Tennessean", 	      
    "TX" => "Texan", 			  
    "UT" => "Utahn", 			  
    "VT" => "Vermonter", 	      
    "VA" => "Virginian", 	      
    "WA" => "Washingtonian", 	  
    "WV" => "West Virginian", 	  
    "WI" => "Wisconsinite", 	  
    "WY" => "Wyomingite" }     

  def Person.state_for_abbrev(abbr)
    return "" if abbr.blank?
    @@STATE_FOR_ABBREV[abbr.upcase]
  end
  
  def Person.resident_for_abbrev(abbr)
    @@RESIDENT_FOR_ABBREV[abbr.upcase]
  end  

  def set_party
     self.party = self.roles.first.party unless self.roles.empty?
  end

  def obj_title
    self.title
  end

end
