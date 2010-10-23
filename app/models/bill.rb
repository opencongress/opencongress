class Bill < ViewableObject

#  acts_as_solr :fields => [{:billtext_txt => :text},:bill_type,:session,{:title_short=>{:boost=>3}}, {:introduced => :integer}],
#               :facets => [:bill_type, :session], :auto_commit => false

  belongs_to :sponsor, :class_name => "Person", :foreign_key => :sponsor_id
  has_many :bill_titles  
  has_many :bill_cosponsors
  has_many :co_sponsors, :through => :bill_cosponsors, :source => :person, :order => 'lastname'
  has_many :actions, :order => 'actions.datetime ASC'
  has_many :bill_committees
  has_many :committees, :through => :bill_committees
  has_many :bill_relations
  has_many :related_bills, :through => :bill_relations, :source => :related_bill
  has_one  :related_bill_session, :through => :bill_relations, :source => :related_bill, :conditions => "bills_relations.relation='session'"
  has_many :bill_subjects
  has_many :subjects, :through => :bill_subjects
  has_many :amendments, :order => 'offered_datetime', :include => :roll_calls
  has_many :roll_calls, :order => 'date DESC'
  has_many :comments, :as => :commentable
  has_many :object_aggregates, :as => :aggregatable
  has_many :bill_referrers
  has_many :bill_votes
  has_one  :last_action, :class_name => "Action", :order => "actions.date DESC"
  has_many :most_recent_actions, :class_name => "Action", :order => "actions.date DESC", :limit => 5
  
  has_many :bill_text_versions
  
  with_options :class_name => 'Commentary', :order => 'commentaries.date DESC' do |c|
    c.has_many :news, :as => :commentariable, :conditions => "commentaries.is_ok = 't' AND commentaries.is_news='t'"
    c.has_many :blogs, :as => :commentariable, :conditions => "commentaries.is_ok = 't' AND commentaries.is_news='f'"
  end

  has_many :videos, :order => "videos.video_date DESC, videos.id"

  has_many :bookmarks, :as => :bookmarkable
  has_many :notebook_links, :as => :notebookable

  has_many :committee_meetings_bills
  has_many :committee_meetings, :through => :committee_meetings_bills

  has_many :committee_reports
  
  has_one :bill_stats
  has_one :bill_fulltext
  
  has_many :friend_emails,
        :as => :emailable,
        :order => 'created_at'
  
  belongs_to :hot_bill_category
  
  has_many :bill_interest_groups,
        :include => :crp_interest_group,
        :order => 'crp_interest_groups.order',
        :dependent => :destroy
  has_many :bill_position_organizations, :dependent => :destroy
  
  has_one :wiki_link, :as => "wikiable"
  
  alias :blog :blogs
  
  attr_accessor :search_relevancy
  attr_accessor :tmp_search_desc
  
  attr_accessor :wiki_summary_holder

  @@DISPLAY_OBJECT_NAME = 'Bill'
                                            
  @@TYPES = {"h" => "H.R.", "s" => "S.", "hj" => "H.J.Res.", "sj" => "S.J.Res.", "hc" => "H.Con.Res.", "sc" => "S.Con.Res.", "hr" => "H.Res.", "sr" => "S.Res."}
  @@TYPES_ORDERED = [ "s", "sj",  "sc",  "sr", "h", "hj", "hc", "hr" ]
  
  @@INVERTED_TYPES = {"hconres"=>"hc", "hres"=>"hr", "hr"=>"h", "hjres"=>"hj", "sjres"=>"sj", "sconres"=>"sc", "s"=>"s", "sres"=>"sr"}

  class << self
    def all_types
      @@TYPES
    end
  
    def all_types_ordered
      @@TYPES_ORDERED
    end
  
    def in_senate
      @@TYPES_ORDERED[0..3]
    end

    def in_house
      @@TYPES_ORDERED[4..7]
    end
  end
  
  def before_save
    # update the bill fulltext search table
    
    if self.id
      # when the bill is new, the bill titles will have just been added to the DB.
      # using raw sql is the only way i've found to get them (the 'force_reload'
      # option on the association does not seem to work.)  if there is a better way
      # if should be implemented
      bts = BillTitle.find_by_sql(["SELECT bill_titles.* FROM bill_titles WHERE bill_id=?", id])
  
      stripped_type = type_name.gsub(/[\.\/]+/,"").downcase # ie, 'hconres'
     
      self.build_bill_fulltext if self.bill_fulltext.nil? 
      self.bill_fulltext.fulltext = "#{type_name}#{number} #{type_name} #{number} #{bill_type}#{number} #{stripped_type}#{number} #{stripped_type} #{number} #{bts.collect(&:title).join(" ")} #{plain_language_summary}"
      self.bill_fulltext.save
    
      # also, set the lastaction field unless it's a brand new record
      self.lastaction = last_action.date if last_action
    end
  end
  
  def display_object_name
    @@DISPLAY_OBJECT_NAME
  end

  def current_bill_text_version
    versions = bill_text_versions.find(:all, :conditions => "bill_text_versions.previous_version IS NULL")
    if versions.empty?
      return nil
    end
        
    v = bill_text_versions.find(:first, :conditions => ["bill_text_versions.previous_version=?", versions.first.version])
    until v.nil?
      versions << v
      v = bill_text_versions.find(:first, :conditions => ["bill_text_versions.previous_version=?", v.version])
    end
    
    versions.last
  end
  
  def top_rated_news_items
     ids = CommentaryRating.count(:id, :group => "commentaries.id", 
                            :include => "commentary", 
                            :conditions => ["commentaries.commentariable_id = ? AND commentaries.commenariable_type='Bill' AND commentaries.is_news = ?", self.id, true], :order => "count_id DESC").collect {|p| p[1] > 1 ? p[0] : nil }.compact
     coms = CommentaryRating.calculate(:avg, :rating, 
                                       :include => "commentary", :conditions => ["commentary_id in (?)", ids],
                                       :group => "commentaries.id", :order => "avg_rating DESC")
  end

  def top_rated_blog_items
     ids = CommentaryRating.count(:id, :group => "commentaries.id", 
                            :include => "commentary", 
                            :conditions => ["commentaries.commentariable_id = ? AND commentaries.commenariable_type='Bill' AND commentaries.is_news = ?", self.id, false], :order => "count_id DESC").collect {|p| p[1] > 1 ? p[0] : nil }.compact
     coms = CommentaryRating.calculate(:avg, :rating, 
                                       :include => "commentary", :conditions => ["commentary_id in (?)", ids],
                                       :group => "commentaries.id", :order => "avg_rating DESC")
  end

  def self.find_with_most_commentary_ratings
    ids = CommentaryRating.count(:id, :group => "commentaries.commentariable_id", :include => "commentary", :conditions => "commentaries.commentariable_type='Bill'", :order => "count_id DESC").collect {|p| p[0]}
    find_all_by_id(ids)
  end
  
  def is_house_bill?
    bill_type.include? "h"
  end
  
  def is_senate_bill?
    bill_type.include? "s"
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
      # check for the link in the wiki DB
      wiki_link = Wiki.wiki_link_for_bill(self.session, "#{self.bill_type.upcase}#{self.number}")
      unless wiki_link.blank?
        WikiLink.create(:wikiable => self, :name => wiki_link, :oc_link => "#{BASE_URL}/bill/#{self.ident}/show")
        link = "#{WIKI_BASE_URL}/#{wiki_link}"
      else
        link = ""
      end
    else
      link = "#{WIKI_BASE_URL}/#{self.wiki_link.name}"
    end
    
    return link

  end

  def wiki_summary
    w = nil
    if self.wiki_summary_holder.nil? and !self.wiki_link.blank?
      w = Wiki.summary_text_for(self.wiki_link.name)
      if w.blank?
        wiki_summary_holder = ''
      else
        wiki_summary_holder = w
      end
    end
    
    return wiki_summary_holder
  end

  def text_comments_count
    Bill.count_by_sql(["SELECT count(*) FROM bill_text_versions INNER JOIN bill_text_nodes ON bill_text_nodes.bill_text_version_id=bill_text_versions.id 
                  INNER JOIN comments ON comments.commentable_id=bill_text_nodes.id 
                  WHERE bill_text_versions.bill_id=? AND comments.commentable_type='BillTextNode'", self.id])
  end
  
  def recent_activity(since = nil)
    items = []
    actions.find(:all, :conditions => ["created_at >= ?", since], :order => "datetime desc")
    items = actions
    items
  end
  
  def recent_activity_mini_list(since = nil)
    host = "dev.opencongress.org"
    host = "www.opencongress.org" if Rails.env.production?
    
    items = []
    self.recent_activity(since).each do |i|
        items << {:sort_date => i.datetime.to_date, :content => i.to_s, :link => {:host => host, :only_path => false, :controller => 'bill', :action => 'show', :id => self.ident}}
    end
    items.group_by{|x| x[:sort_date]}.to_a.sort{|a,b| b[0]<=>a[0]}
  end

  # Returns the number of people tracking this bill, as well as suggestions of what other people
  # tracking this bill are also tracking.
  def tracking_suggestions

    facet_results_hsh = {:my_people_tracked_facet => [], :my_issues_tracked_facet => [], :my_bills_tracked_facet => []}
    my_trackers = 0

    users = User.find_by_solr('placeholder:placeholder', :facets => {:fields => [:my_people_tracked, :my_issues_tracked, :my_bills_tracked], 
                                                      :browse => ["my_bills_tracked:#{self.ident}"], 
                                                      :limit => 6, :zeros => false, :sort =>  true}, :limit => 1)
    facets = users.facets

    facet_results_ff = facets['facet_fields']
    if facet_results_ff && facet_results_ff != []
      
      facet_results_ff.each do |fkey, fvalue|
        facet_results = facet_results_ff[fkey]
      
        #solr running through acts as returns as a Hash, or an array if running through tomcat...hence this stuffs
        facet_results_temp_hash = Hash[*facet_results] unless facet_results.class.to_s == "Hash"
        facet_results_temp_hash = facet_results if facet_results.class.to_s == "Hash"

        facet_results_temp_hash.each do |key,value|
          if key == self.ident.to_s && fkey == "my_bills_tracked_facet"
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

    users = User.find_by_solr('placeholder:placeholder', :facets => {:fields => [:my_bills_supported, :my_approved_reps, :my_approved_sens, :my_disapproved_reps, :my_disapproved_sens, :my_bills_opposed], 
                                                      :browse => ["my_bills_supported:#{self.id}"], 
                                                      :limit => 6, :zeros => false, :sort =>  true}, :limit => 1)
                                                      logger.debug users.to_yaml
                                                      
    return parse_facets(users.facets, "my_bills_supported_facet", ["my_approved_reps_facet","my_approved_sens_facet","my_disapproved_reps_facet","my_disapproved_sens_facet",
                                                                   "my_bills_supported_facet", "my_bills_opposed_facet"])
    
  end
  
  def oppose_suggestions
    users = User.find_by_solr('placeholder:placeholder', :facets => {:fields => [:my_bills_supported, :my_approved_reps, :my_approved_sens, :my_disapproved_reps, :my_disapproved_sens, :my_bills_opposed], 
                                                      :browse => ["my_bills_opposed:#{self.id}"], 
                                                      :limit => 6, :zeros => false, :sort =>  true}, :limit => 1)
                                                      logger.debug users.to_yaml
                                                      
    return parse_facets(users.facets, "my_bills_opposed_facet", ["my_approved_reps_facet","my_approved_sens_facet","my_disapproved_reps_facet","my_disapproved_sens_facet",
                                                                 "my_bills_supported_facet", "my_bills_opposed_facet"])
        
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

  # returns the battle royale index
  def place_in_battle_royale_100
    b = Bill.find_all_by_most_user_votes_for_range(nil, {:limit => 100, :offset => 0})
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
    if page
      return {:controller => :battle_royale, :action => :index, :page => page, :bill => self.ident, :timeframe => "AllTime"}
    else
      return nil
    end
  end

  def to_light_xml(options = {})
    default_options = {:except => [:rolls, :hot_bill_category_id, :summary, :fti_titles,:bookmark_count_2,
                                   :fti_names,:current_support_pb, :support_count_1, :rolls, :hot_bill_category_id, 
                                   :support_count_2, :vote_count_2], 
                                :methods => [:title_full_common, :status, :ident]
                                }
    self.to_xml(default_options.merge(options))
  end

  def to_medium_xml(options = {})
    default_options = {:except => [:rolls, :hot_bill_category_id, :summary, :fti_titles], 
                                :methods => [:title_full_common, :status, :ident], 
                                :include => {:co_sponsors => {:methods => [:oc_user_comments, :oc_users_tracking]}, 
                                             :sponsor => {:methods => [:oc_user_comments, :oc_users_tracking]}, 
                                             :bill_titles => {},
                                             :most_recent_actions => {}
                                             }
                                }
    self.to_xml(default_options.merge(options))
  end

  class << self
    # return bill actions since last X
    def find_changes_since_for_bills_tracked(current_user)
       time_since = current_user.previous_login_date || 20.days.ago
       time_since = 200.days.ago if Rails.env.development?
       ids = current_user.bill_bookmarks.collect{|p| p.bookmarkable_id}
       find_by_sql(["select bills.*, total_actions.action_count as actionn_count,
                        total_blogs.blog_count as blogss_count, total_news.news_count as newss_count,
                        total_comments.comments_count as commentss_count from bills
                    LEFT OUTER JOIN (select count(actions.id) as action_count, 
                        actions.bill_id as bill_id_1 FROM actions WHERE 
                        actions.datetime > '#{time_since.to_s(:db)}' 
                        AND actions.bill_id in (#{ids.join(",")})
                        group by bill_id_1) total_actions ON 
                        total_actions.bill_id_1 = bills.id 
                    LEFT OUTER JOIN (select count(commentaries.id) as blog_count,
                        commentaries.commentariable_id as bill_id_2 FROM commentaries WHERE
                        commentaries.commentariable_id IN (#{ids.join(",")}) AND
                        commentaries.commentariable_type='Bill' AND
                        commentaries.is_ok = 't' AND commentaries.is_news='f' AND
                        commentaries.date > '#{time_since.to_s(:db)}' 
                        group by commentaries.commentariable_id) 
                        total_blogs ON total_blogs.bill_id_2 = bills.id 
                    LEFT OUTER JOIN (select count(commentaries.id) as news_count,
                        commentaries.commentariable_id as bill_id_3 FROM commentaries WHERE
                        commentaries.commentariable_id IN (#{ids.join(",")}) AND
                        commentaries.commentariable_type='Bill' AND
                        commentaries.is_ok = 't' AND commentaries.is_news='t' AND
                        commentaries.date > '#{time_since.to_s(:db)}' 
                        group by commentaries.commentariable_id)
                        total_news ON total_news.bill_id_3 = bills.id 
                    LEFT OUTER JOIN (select count(comments.id) as comments_count,
                        comments.commentable_id as bill_id_4 FROM comments WHERE
                        comments.created_at > '#{time_since.to_s(:db)}' AND
                        comments.commentable_id in (#{ids.join(",")}) AND
                        comments.commentable_type = 'Bill' GROUP BY comments.commentable_id)
                        total_comments ON total_comments.bill_id_4 = bills.id WHERE bills.id IN (?)", current_user.bill_bookmarks.collect{|p| p.bookmarkable_id}])
    end 

    # return bill actions since last X
    def find_user_data_for_tracked_bill(bill, current_user)
       time_since = current_user.previous_login_date || 20.days.ago
       time_since = 200.days.ago if Rails.env.development?
       find_by_id(bill.id,
                      :select => "bills.*, (select count(actions.id) from actions where actions.datetime > '#{time_since.to_s(:db)}' AND bill_id = #{bill.id} ) as action_count,
                          (select count(commentaries.id) FROM commentaries 
                               WHERE commentaries.commentariable_id = #{bill.id}
                                 AND commentaries.commentariable_type='Bill'
                                 AND commentaries.is_ok = 't' 
                                 AND commentaries.is_news='f'
                                 AND commentaries.date > '#{time_since.to_s(:db)}') as blog_count,
                          (select count(commentaries.id) FROM commentaries 
                               WHERE commentaries.commentariable_id = #{bill.id}
                                  AND commentaries.commentariable_type='Bill'
                                  AND commentaries.is_ok = 't' 
                                  AND commentaries.is_news='t'
                                  AND commentaries.date > '#{time_since.to_s(:db)}') as newss_count,
                          (select count(comments.id) FROM comments
                               WHERE comments.created_at > '#{time_since.to_s(:db)}'
                                 AND comments.commentable_type='Bill'
                                 AND comments.commentable_id = #{bill.id}) as comment_count")
    end                          
    
    def find_all_by_most_user_votes_for_range(range, options)
      range = 2.years.to_i if range.nil?
      possible_orders = ["vote_count_1 desc", "vote_count_1 asc", "current_support_pb asc", 
                         "current_support_pb desc", "bookmark_count_1 asc", "bookmark_count_1 desc", 
                         "support_count_1 desc", "support_count_1 asc", "total_comments asc", "total_comments desc"]
      logger.debug options.to_yaml
      order = options[:order] ||= "vote_count_1 desc"
      search = options[:search]
      if possible_orders.include?(order)

        limit = options[:limit] ||= 20
        offset = options[:offset] ||= 0
        not_null_check = order.split(' ').first

        query = "
            SELECT
              bills.*,
              #{search ? "rank(bill_fulltext.fti_names, ?, 1) as tsearch_rank, " : "" }
              current_period.vote_count_1 as vote_count_1,
              current_period.support_count_1 as support_count_1,
              (total_counted.total_count - total_supported.total_support) as total_support,
              current_period.current_support_pb as current_support_pb,
              comments_total.total_comments as total_comments,
              current_period_book.bookmark_count_1 as bookmark_count_1,
              previous_period.vote_count_2 as vote_count_2,
              previous_period.support_count_2 as support_count_2, 
              total_supported.total_support as total_opposed,
              total_counted.total_count as total_count
            FROM
              #{search ? "bill_fulltext," : ""}
              bills 
            INNER JOIN (
              select bill_votes.bill_id  as bill_id_1, 
              count(bill_votes.bill_id) as vote_count_1, 
              sum(bill_votes.support) as support_count_1,
              (count(bill_votes.bill_id) - sum(bill_votes.support)) as current_support_pb  
              FROM bill_votes 
              WHERE created_at > ? group by bill_id_1)
            current_period ON bills.id = current_period.bill_id_1
            LEFT OUTER JOIN (
              select bill_votes.bill_id as bill_id_3, 
              sum(bill_votes.support) as total_support 
              FROM bill_votes 
              GROUP BY bill_votes.bill_id) 
            total_supported ON bills.id = total_supported.bill_id_3
            LEFT OUTER JOIN (
              select bill_votes.bill_id as bill_id_4, 
              count(bill_votes.support) as total_count 
              FROM bill_votes 
              GROUP BY bill_votes.bill_id) 
            total_counted ON bills.id = total_counted.bill_id_4
            LEFT OUTER JOIN (
              select comments.commentable_id as bill_id_5,
              count(comments.id) as total_comments 
              FROM comments 
              WHERE created_at > ? AND 
              comments.commentable_type = 'Bill' 
              GROUP BY comments.commentable_id) 
            comments_total ON bills.id = comments_total.bill_id_5 
            LEFT OUTER JOIN (
              select bill_votes.bill_id as bill_id_2, 
              count(bill_votes.bill_id) as vote_count_2, 
              sum(bill_votes.support) as support_count_2 
              FROM bill_votes 
              WHERE created_at > ? AND 
              created_at <= ? 
              GROUP BY bill_id_2) 
            previous_period ON bills.id = previous_period.bill_id_2
            LEFT OUTER JOIN (
              select bookmarks.bookmarkable_id as bill_id_1, 
               count(bookmarks.bookmarkable_id) as bookmark_count_1 
               FROM bookmarks
                   WHERE created_at > ?
               GROUP BY bill_id_1) 
            current_period_book ON bills.id = current_period_book.bill_id_1
            WHERE #{not_null_check} IS NOT NULL
            #{search ? "AND bill_fulltext.fti_names @@ to_tsquery('english', ?)
            AND bills.id = bill_fulltext.bill_id" : ""}
            ORDER BY #{order} 
            LIMIT #{limit} 
            OFFSET #{offset}"

        query_params = [range.seconds.ago,range.seconds.ago, (range*2).seconds.ago, range.seconds.ago, range.seconds.ago]

        if search
          # Plug the search parameters into the query parmaeters
          query_params.unshift(search)
          query_params.push(search)
        end

        Bill.find_by_sql([query, *query_params])
      else 
        return []
      end
    end

    def count_all_by_most_user_votes_for_range(range, options)
      possible_orders = ["vote_count_1 desc", "vote_count_1 asc", "current_support_pb asc", 
                         "current_support_pb desc", "bookmark_count_1 asc", "bookmark_count_1 desc", 
                         "support_count_1 desc", "support_count_1 asc", "total_comments asc", "total_comments desc"]
      logger.debug options.to_yaml
      order = options[:order] ||= "vote_count_1 desc"
      search = options[:search]
      if possible_orders.include?(order)
        join_query = ""
        join_query_bind = []
        case order.split.first
          when "bookmark_count_1"
            join_query = "INNER JOIN (select bookmarks.bookmarkable_id as bill_id
                   FROM bookmarks
                  WHERE created_at > ? GROUP BY bookmarkable_id) 
               current_period_book ON bills.id=current_period_book.bill_id"
            join_query_bind = [range.seconds.ago]
          when "total_comments"
            join_query = "INNER JOIN (select comments.commentable_id as bill_id
                FROM comments 
                   WHERE created_at > ? AND 
                         comments.commentable_type = 'Bill'
                GROUP BY comments.commentable_id) 
            comments_total ON bills.id=comments_total.bill_id"
            join_query_bind = [range.seconds.ago]
        end

        query = "SELECT count(bills.*)
            FROM
              #{search ? "bill_fulltext," : ""}
              bills 
             INNER JOIN (select bill_votes.bill_id
                 FROM bill_votes WHERE created_at > ?
                 GROUP BY bill_votes.bill_id) current_period
             ON bills.id = current_period.bill_id
             #{join_query}
            #{search ? "WHERE bill_fulltext.fti_names @@ to_tsquery('english', ?) AND bills.id = bill_fulltext.bill_id" : ""}"
        query_params = [range.seconds.ago, *join_query_bind]

        if search
          query_params.push(search)
        end

        k = Bill.count_by_sql([query, *query_params])
        return k
      else 
        return []
      end
    end

    # Why are these next two methods in Bill if they just return BillVote stuff?
    def total_votes_last_period(minutes)
      return BillVote.calculate(:count, :all, :conditions => {:created_at => (Time.new - (minutes*2))..(Time.new - (minutes))})
    end

    def total_votes_this_period(minutes)
      return BillVote.calculate(:count, :all, :conditions => ["created_at > ?", Time.new - (minutes)])
    end

    def percentage_difference_in_periods(minutes)
      return (Bill.total_votes_last_period(minutes).to_f) / Bill.total_votes_this_period(minutes).to_f
    end

  end # << self

  def adjusted_votes_this_period(total,this_period,minutes)
    return this_period.to_f * total.to_f
  end

  def is_vote_hot?(total,previous_period,this_period,minutes)
    ajvtp = self.adjusted_votes_this_period(total,this_period,minutes)
    return true if ( ajvtp > 3 && ( (ajvtp  / 6) > previous_period ) )
  end

  def is_vote_cold?(total,previous_period,this_period,minutes)
    ajvtp = self.adjusted_votes_this_period(total,this_period,minutes)
    return true if ( ajvtp > 3 && ( ajvtp < ( previous_period / 1.01) ) )
  end

  def chamber
    if bill_type.starts_with? "h"
      "house"
    else
      "senate"
    end
  end
  
  def other_chamber
    if bill_type.starts_with? "h"
      "senate"
    else
      "house"
    end
  end
  
  class << self
    def find_by_ident(ident_string, find_options = {})
      session, bill_type, number = Bill.ident ident_string
      Bill.find_by_session_and_bill_type_and_number(session, bill_type, number, find_options)
    end

    def find_all_by_ident(ident_array, find_options = {})
      the_bill_conditions = []
      the_bill_params = {}
      limit = find_options[:limit] != 20
      round = 1
      ident_array.each do |ia|
        session, bill_type, number = Bill.ident ia
        the_bill_conditions << "(session = :session#{round} AND bill_type = :bill_type#{round} AND number = :number#{round})"
        the_bill_params.merge!({"session#{round}".to_sym => session, "bill_type#{round}".to_sym => bill_type, "number#{round}".to_sym => number})
        round = round + 1
      end
      Bill.find(:all, :conditions => ["#{the_bill_conditions.join(' OR ')}", the_bill_params], :limit => find_options[:limit])
  #    Bill.find_by_session_and_bill_type_and_number(session, bill_type, number, find_options)
    end
  
    def long_type_to_short(type)
      @@INVERTED_TYPES[type.downcase.gsub(/\s|\./, "")]
    end

    def short_type_to_long(type)
      @@TYPES[type]
    end
  
    def session_from_date(date)
      session_a = CONGRESS_START_DATES.to_a.sort { |a, b| a[0] <=> b[0] }

      session_a.each_with_index do |s, i|
        return nil if s == session_a.last
        s_date = Date.parse(s[1])
        e_date = Date.parse(session_a[i+1][1])

        if date >= s_date and date < e_date
          return s[0]
        end
      end
      return nil
    end
  
    def find_hot_bills(order = 'hot_bill_categories.name', options = {})
      # not used right now.  more efficient to loop through categories
      # probably just need to add an index to hot_bill_category_id
      Bill.find(:all, :conditions => "bills.hot_bill_category_id IS NOT NULL", :include => :hot_bill_category, 
                :order => order, :limit => options[:limit])
    end
  
    def top20_viewed
      bills = ObjectAggregate.popular('Bill')
      
      (bills.select {|b| b.stats.entered_top_viewed.nil? }).each do |bv|
        bv.stats.entered_top_viewed = Time.now
        bv.save
      end
    
      (bills.sort { |b1, b2| b2.stats.entered_top_viewed <=> b1.stats.entered_top_viewed })
    end

    def top5_viewed
      bills = ObjectAggregate.popular('Bill', DEFAULT_COUNT_TIME, 5)
      
      (bills.select {|b| b.stats.entered_top_viewed.nil? }).each do |bv|
        bv.stats.entered_top_viewed = Time.now
        bv.save
      end
    
      (bills.sort { |b1, b2| b2.stats.entered_top_viewed <=> b1.stats.entered_top_viewed })
    end

    def top20_commentary(type = 'news')
      bills = Bill.find_by_most_commentary(type, num = 20)
    
      date_method = :"entered_top_#{type}"
      (bills.select {|b| b.stats.send(date_method).nil? }).each do |bv|
        bv.stats.write_attribute(date_method, Time.now)
        bv.save
      end
    
      (bills.sort { |b1, b2| b2.stats.send(date_method) <=> b1.stats.send(date_method) })
    end
  
    def random(limit)
      Bill.find_by_sql ["SELECT * FROM (SELECT random(), bills.* FROM bills ORDER BY 1) as bs LIMIT ?;", limit]
    end
  end # class << self
  
  def log_referrer(referrer)
    unless (referrer.blank? || /opencongress\.org/.match(referrer) || /google\.com/.match(referrer))
      self.bill_referrers.find_or_create_by_url(referrer)
    end
  end
  
  def unique_referrers(since = 2.days)
    ref_views = PageView.find(:all, 
                              :select => "DISTINCT(page_views.referrer)",
                              :conditions => ["page_views.referrer IS NOT NULL AND 
                                               page_views.viewable_id = ? AND
                                               page_views.viewable_type = 'Bill' AND
                                               page_views.created_at > ?", id, since.ago])
    ref_views.collect { |v| v.referrer }
  end
  

  
  def subject
    #most popular subject that is not in the top X
    num = 8
    
    if subjects.empty?
      Subject.find_by_term("Congress")
    else
      @top ||= Subject.find(:all).sort_by { |b| b.bill_count }.reverse.first(num)
      subjects.sort_by { |b| b.bill_count }.reverse.find { |s| ! @top.include?(s) }
    end
  end

  def commentary_count(type = 'news', since = DEFAULT_COUNT_TIME)
    return @attributes['article_count'] if @attributes['article_count']
    
    if type == 'news'
      self.news.find(:all, :conditions => [ "commentaries.date > ?", since.ago]).size
    else
      self.blogs.find(:all, :conditions => [ "commentaries.date > ?", since.ago]).size
    end
  end
  
  def stats
    self.build_bill_stats unless self.bill_stats
    self.bill_stats
  end
  
  # returns a float between 0 and 1 corresponding to the percentage of it's blog and news
  # articles that are less than a week old
  def commentary_freshness
    total_news = self.news.size
    total_blogs = self.blogs.size
    if (total_news + total_blogs) > 0
      fresh_news = self.news.select { |n| n.date > DEFAULT_COUNT_TIME.ago }
      fresh_blogs = self.blogs.select { |b| b.date > DEFAULT_COUNT_TIME.ago }
      return ((fresh_news.size.to_f + fresh_blogs.size.to_f) / (total_news.to_f + total_blogs.to_f))
    else
      return 0
    end
  end
  
  # returns a float between 0 and 1 corresponding to the percentage of it's actions
  # that are less than a month old
  def activity_freshness
    actions.size ? ((actions.select { |a| a.datetime > 30.days.ago}).size.to_f / actions.size.to_f ) : 0
  end

  class << self
    def sponsor_count
      Bill.count(:all, :conditions => ["session = ?", DEFAULT_CONGRESS], :group => "sponsor_id").sort {|a,b| b[1]<=>a[1]}
    end

    def cosponsor_count
      Bill.count(:all, :include => [:bill_cosponsors], :conditions => ["bills.session = ?", DEFAULT_CONGRESS], :group => "bills_cosponsors.person_id").sort {|a,b| b[1]<=>a[1]}
    end
  
    def find_by_most_commentary(type = 'news', num = 5, since = DEFAULT_COUNT_TIME, congress = DEFAULT_CONGRESS, bill_types = ["h", "hc", "hj", "hr", "s", "sc", "sj", "sr"])

      is_news = (type == "news") ? true : false
    
      Bill.find_by_sql(["SELECT bills.*, top_bills.article_count AS article_count FROM bills
                         INNER JOIN
                         (SELECT commentaries.commentariable_id, count(commentaries.commentariable_id) AS article_count
                          FROM commentaries 
                          WHERE commentaries.commentariable_type='Bill' AND
                                commentaries.date > ? AND
                                commentaries.is_news=? AND
                                commentaries.is_ok='t'                             
                          GROUP BY commentaries.commentariable_id
                          ORDER BY article_count DESC) top_bills
                         ON bills.id=top_bills.commentariable_id
                         WHERE bills.session = ? AND bills.bill_type IN (?)
                         ORDER BY article_count DESC LIMIT ?", 
                        since.ago, is_news, congress, bill_types, num])
    end

    def find_rushed_bills(congress = DEFAULT_CONGRESS, rushed_time = 259200, show_resolutions = false)
      resolution_condition = show_resolutions ? "" : " AND (bills.bill_type = 'h' OR bills.bill_type = 's')"
    
      Bill.find_by_sql(["SELECT * FROM bills INNER JOIN 
                         (SELECT actions.date AS intro_date, actions.bill_id AS intro_id 
                          FROM actions WHERE actions.action_type='introduced') intro_action
                         ON intro_action.intro_id=bills.id INNER JOIN
                         (SELECT actions.date AS vote_date, actions.bill_id AS vote_id 
                          FROM actions WHERE actions.action_type='vote' AND vote_type='vote' GROUP BY vote_id, vote_date) vote_action
                         ON vote_action.vote_id=bills.id
                         WHERE bills.session=? AND vote_action.vote_date - intro_action.intro_date < ? #{resolution_condition}
                         ORDER BY vote_date DESC", congress, rushed_time])
    end

    def find_gpo_consideration_rushed_bills(congress = DEFAULT_CONGRESS, rushed_time = 259200, show_resolutions = false)
      # rushed time not working correctly for some reason (adapter is changing...)
 
      resolution_condition = show_resolutions ? "" : " AND (bills.bill_type = 'h' OR bills.bill_type = 's')"
    
      Bill.find_by_sql(["SELECT * FROM bills INNER JOIN 
                         (SELECT gpo_billtext_timestamps.created_at AS gpo_date, gpo_billtext_timestamps.session AS gpo_session,
                                 gpo_billtext_timestamps.bill_type AS gpo_bill_type, gpo_billtext_timestamps.number AS gpo_number
                          FROM gpo_billtext_timestamps WHERE version='ih' OR version='is') gpo_action
                         ON (gpo_action.gpo_session=bills.session AND gpo_action.gpo_bill_type=bills.bill_type AND gpo_action.gpo_number=bills.number)
                         INNER JOIN
                         (SELECT MIN(actions.datetime) AS consideration_date, actions.bill_id AS consideration_id 
                          FROM actions, action_references WHERE actions.action_type='action' AND actions.id=action_references.action_id AND action_references.label='consideration' AND actions.text NOT LIKE '%Committee%' GROUP BY actions.bill_id) consideration_action
                         ON consideration_action.consideration_id=bills.id
                         WHERE bills.session=? AND ((consideration_action.consideration_date - gpo_action.gpo_date < '259200 seconds'::interval) OR gpo_action.gpo_date IS NULL OR bills.id = 54463)
                               #{resolution_condition}
                         ORDER BY consideration_date DESC", congress])
    end
  end

  def top_recipients_for_all_interest_groups(disposition = 'support', chamber = 'house', num = 10)
    
    groups = self.bill_interest_groups.select{|g| g.disposition == disposition}
    groups_ids = groups.collect { |g| g.crp_interest_group.osid }
    
    title = (chamber == 'house') ? 'Rep.' : 'Sen.'
    Person.find_by_sql(["SELECT people.*, top_recips_ind.ind_contrib_total, top_recips_pac.pac_contrib_total, (COALESCE(top_recips_ind.ind_contrib_total, 0) + COALESCE(top_recips_pac.pac_contrib_total, 0)) AS contrib_total FROM people
      LEFT JOIN 
        (SELECT recipient_osid, SUM(crp_contrib_individual_to_candidate.amount) as ind_contrib_total 
         FROM crp_contrib_individual_to_candidate
         WHERE crp_interest_group_osid IN (?) AND cycle=? AND crp_contrib_individual_to_candidate.contrib_type IN ('10', '11', '15 ', '15', '15E', '15J', '22Y')
         GROUP BY recipient_osid) 
        top_recips_ind ON people.osid=top_recips_ind.recipient_osid
      LEFT JOIN
        (SELECT recipient_osid, SUM(crp_contrib_pac_to_candidate.amount) as pac_contrib_total 
         FROM crp_contrib_pac_to_candidate
         WHERE crp_contrib_pac_to_candidate.crp_interest_group_osid IN (?) AND crp_contrib_pac_to_candidate.cycle=?
         GROUP BY crp_contrib_pac_to_candidate.recipient_osid) 
        top_recips_pac ON people.osid=top_recips_pac.recipient_osid
     WHERE people.title=?
     ORDER BY contrib_total DESC
     LIMIT ?", groups_ids, CURRENT_OPENSECRETS_CYCLE, groups_ids, CURRENT_OPENSECRETS_CYCLE, title, num])
  end
  
  class << self
    def client_id_to_url(client_id)
      client_id.slice!(/\d+_/)
      long_type_to_short(client_id)
    end

    def from_param(param)
      md = /^(\d+)_(hconres|hres|hr|hjres|sjres|sconres|s|sres)(\d+)$/.match(param)
      return [nil, nil, nil] unless md
      id = md.captures[0].to_i
      t = Bill.long_type_to_short(md.captures[1])
      num = md.captures[2].to_i
      (id || t | num) ? [id, t, num] : [nil, nil, nil]
    end
    
    def canonical_name(name)
      "#{name.gsub(/[\.\s\/]+/,"").downcase}"
    end

    def ident(param_id)
      md = /(\d+)-([hs][jcr]?)(\d+)$/.match(canonical_name(param_id))
      md ? md.captures : [nil, nil, nil]
    end
  end # class << self

  def ident
    "#{session}-#{bill_type}#{number}"
  end
  
  def to_param
    self.ident
  end

  def atom_id_as_feed
    "tag:opencongress.org,#{Time.at(introduced).strftime("%Y-%m-%d")}:/bill_feed/#{ident}"
  end

  def atom_id_as_entry
    "tag:opencongress.org,#{Time.at(introduced).strftime("%Y-%m-%d")}:/bill/#{ident}"
  end

  # used when sorting with other types of objects
  def sort_date
    Time.at(self.introduced)
  end

  def rss_date
    Time.at(self.introduced)
  end
  
  def last_5_actions
    actions.find(:all, :order => "date DESC", :limit => 5)
  end
  
  def status(options = {})
    status_hash = self.bill_status_hash
    return status_hash['steps'][status_hash['current_step']]['text']
  end

  def status_class
    status_hash = self.bill_status_hash
    return status_hash['steps'][status_hash['current_step']]['class']
  end


  def next_step
    status_hash = self.bill_status_hash
    return status_hash['steps'][status_hash['current_step'] + 1] ? 
           status_hash['steps'][status_hash['current_step'] + 1]['text'] : nil
  end
  
  def hours_to_first_attempt_to_pass
    (originating_chamber_vote.date - introduced_action.date) / 3600
  end
  
  ## bill title methods
  
  def type_name
    @@TYPES[bill_type]
  end

  def title_short
    title = short_title
    title ? "#{title.title}" : "#{type_name}#{number}"
  end
  
  def typenumber # just the type and number, ie H.R.1591
    "#{type_name}#{number}"
  end

  def title_official # just the official title
    official_title ? "#{official_title.title}" : ""
  end
  
  def title_popular_only # popular or short, returns empty string if one doesn't exist
    title = default_title || popular_title || short_title
    
    title ? "#{title.title}" : ""
  end
  
  def title_common # popular or short or official, returns empty string if one doesn't exist
    title = default_title || popular_title || short_title || official_title
    
    title ? "#{title.title}" : ""
  end
  
  def title_full_official # bill type, number and official title
    title = official_title
    
    title ? "#{@@TYPES[bill_type]}#{number} #{title.title}" : ""
  end
  
  def title_full_common # bill type, number and popular, short or official title
    title = default_title || popular_title || short_title || official_title
    
    title ? "#{@@TYPES[bill_type]}#{number} #{title.title}" : ""
  end
  
  def title_for_share
    typenumber
  end

  # methods for progress
  def introduced_action
    actions.select { |a| a.action_type == 'introduced' }.first
  end
  
  def originating_chamber_vote
    actions.select { |a| (a.action_type == 'vote' and a.vote_type == 'vote') }.last
  end
  
  def other_chamber_vote
    actions.select { |a| (a.action_type == 'vote' and a.vote_type == 'vote2') }.last
  end
  
  def presented_to_president_action
    actions.select { |a| a.action_type == 'topresident' }.first
  end
  
  def signed_action
    actions.select { |a| a.action_type == 'signed' }.first
  end
  
  def vetoed_action
    actions.select { |a| a.action_type == 'vetoed' }.first
  end
  
  def override_vote
    actions.select { |a| (a.action_type == 'vote' and a.vote_type == 'override') }.first
  end
  
  def enacted_action
    actions.select { |a| a.action_type == 'enacted' }.last
  end
  
  # returns a hash with info on each step of the bill's progress
  def bill_status_hash
    status_hash = { "steps" => [] }
    current_step = 0

    if a = self.introduced_action
      status_hash['steps'] << { 'text' => 'Introduced', 'class' => 'passed first', 'date' => a.datetime }
    else
      status_hash['steps'] << { 'text' => 'Introduced', 'class' => 'pending' }
    end
    
    status_hash['current_step'] = current_step
    current_step += 1
    
    if a = self.originating_chamber_vote
      roll_id = a.roll_call ? a.roll_call.id : ""

      if a.result == 'pass'
        status_hash['steps'] << { 'text' => "#{self.chamber.capitalize} Passed", 'result' => 'Passed', 
            'class' => 'passed', 'date' => a.datetime, 'roll_id' => roll_id }
         unless (self.bill_type == 'h' or self.bill_type == 's') # is resolution - is done
           status_hash['steps'] << { 'text' => 'Resolution<br/>Passed', 'result' => 'Passed', 'class' => 'is_res', 'date' => a.datetime, 'roll_id' => roll_id }
         end
      else
        status_hash['steps'] << { 'text' => " #{self.chamber.capitalize} Defeats", 'result' => 'Failed', 
                                  'class' => 'failed', 'date' => a.datetime, 'roll_id' => roll_id }
      end
      
      status_hash['current_step'] = current_step
    else
      status_hash['steps'] << { 'text' => "#{self.chamber.capitalize} Passes", 
                                'class' => 'pending', 'result' => 'Pending' }
      unless (self.bill_type == 'h' or self.bill_type == 's') # is resolution pending
           status_hash['steps'] << { 'text' => 'Resolution Passed', 'class' => 'becomes_res', 'result' => 'Pending' }
      end
    end
 
    current_step += 1
        
    if (self.bill_type == 'h' or self.bill_type == 's')
      if a = self.other_chamber_vote
        roll_id = a.roll_call ? a.roll_call.id : ""
        if a.result == 'pass'
          status_hash['steps'] << { 'text' => "#{self.other_chamber.capitalize} Passed", 'result' => 'Passed', 
                                    'class' => 'passed', 'date' => a.datetime, 'roll_id' => roll_id }
        else
          status_hash['steps'] << { 'text' => "#{self.other_chamber.capitalize} Defeats", 'result' => 'Failed', 
                                    'class' => 'failed', 'date' => a.datetime, 'roll_id' => roll_id }                                    
        end
        
        status_hash['current_step'] = current_step
      else
        status_hash['steps'] << { 'text' => "#{self.other_chamber.capitalize} Passes", 
                                  'class' => 'pending', 'result' => 'Pending' }
      end
         
      current_step += 1
      
      if a = self.signed_action
        status_hash['steps'] << { 'text' => 'President Signed', 'result' => 'Passed', 'class' => 'passed', 'date' => a.datetime }
        status_hash['current_step'] = current_step
      elsif a = self.vetoed_action
        status_hash['steps'] << { 'text' => 'President Vetoed', 'result' => 'Failed', 'class' => 'failed', 'date' => a.datetime }
        status_hash['current_step'] = current_step
        
        # check for overridden, otherwise, just return here
        if a = self.override_vote
          roll_id = a.roll_call ? a.roll_call.id : ""
          current_step += 1          
          status_hash['current_step'] = current_step     
          
          if a.result == 'pass'
            status_hash['steps'] << { 'text' => "Override Succeeds", 'result' => 'Passed', 
                                      'class' => 'passed', 'date' => a.datetime, 'roll_id' => roll_id }
          else
            status_hash['steps'] << { 'text' => "Override Defeated", 'result' => 'Failed', 
                                      'class' => 'failed', 'date' => a.datetime, 'roll_id' => roll_id }
            return status_hash                              
          end 
        else
          return status_hash
        end
      else
        status_hash['steps'] << { 'text' => 'President Signs', 'class' => 'pending', 'result' => 'Pending' }
      end
      
      current_step += 1
      
      if a = self.enacted_action
        status_hash['steps'] << { 'text' => 'Bill Is Law', 'result' => 'Passed', 'class' => 'is_law', 'date' => a.datetime }
        status_hash['current_step'] = current_step          
      else
        status_hash['steps'] << { 'text' => 'Bill Becomes Law', 'class' => 'becomes_law', 'result' => 'Pending' }
      end
          
    end
    
    return status_hash
  end
    
  def self.full_text_search(q, options = {})
    congresses = options[:congresses] || DEFAULT_CONGRESS
    
    s_count = Bill.count_by_sql(["SELECT COUNT(*) FROM bills, bill_fulltext
          WHERE bills.session IN (?) AND
            bill_fulltext.fti_names @@ to_tsquery('english', ?) AND
            bills.id = bill_fulltext.bill_id", options[:congresses] || DEFAULT_CONGRESS, q])

    Bill.paginate_by_sql(["SELECT bills.*, rank(bill_fulltext.fti_names, ?, 1) as tsearch_rank FROM bills, bill_fulltext
                               WHERE bills.session IN (?) AND
                                     bill_fulltext.fti_names @@ to_tsquery('english', ?) AND
                                     bills.id = bill_fulltext.bill_id
                               ORDER BY hot_bill_category_id, lastaction DESC", q, options[:congresses], q],
                :per_page => DEFAULT_SEARCH_PAGE_SIZE, :page => options[:page], :total_entries => s_count)
  end

  def billtext_txt
      begin
        # open html from file for now
        path = "#{GOVTRACK_BILLTEXT_PATH}/#{session}/#{bill_type}/"

        # use the symlink to find the current version of the text
        realpath = Pathname.new("#{path}/#{bill_type}#{number}.txt").realpath
        current_file = /\/([a-z0-9]*)\.txt/.match(realpath).captures[0]
            
        @bill_text = File.open(realpath).read
      rescue
        @bill_text = nil
      end
      @bill_text
  end

  def self.b_rb
    Bill.rebuild_solr_index(10) do |bill, options| 
      bill.find(:all, options.merge({:conditions => ["session = ?", DEFAULT_CONGRESS]})) 
    end
  end

  # fragment cache methods

  def fragment_cache_key
    "bill_#{id}"
  end
  
  def expire_govtrack_fragments
    fragments = []
    
    fragments << "#{fragment_cache_key}_header"
    
    FragmentCacheSweeper::expire_fragments(fragments)
  end
  
  def self.expire_meta_govtrack_fragments
    fragments = []
    
    fragments << "bill_all_index"

    FragmentCacheSweeper::expire_fragments(fragments)    
  end
  
  def expire_commentary_fragments(type)
    FragmentCacheSweeper::expire_commentary_fragments(self, type)
  end
  
  # the following isn't called on an instance but rather, static-ly (sp?)
  def self.expire_meta_commentary_fragments
    commentary_types = ['news', 'blog']
    
    fragments = []

    fragments << "frontpage_bill_mostnews"
    fragments << "frontpage_bill_mostblogs"
    
    commentary_types.each do |ct|
      [7, 14, 30].each do |d|
        fragments << "bill_meta_most_#{ct}_#{d.days}"
      end
    end
    
    FragmentCacheSweeper::expire_fragments(fragments)
  end

  def obj_title
    typenumber
  end

  private

  def official_title
    bill_titles.select { |t| t.title_type == 'official' }.first
  end
  
  def short_title
    bill_titles.select { |t| t.title_type == 'short' }.first
  end
  
  def popular_title
    bill_titles.select { |t| t.title_type == 'popular' }.first
  end
  
  def default_title
    bill_titles.select { |t| t.is_default == true }.first
  end

end
