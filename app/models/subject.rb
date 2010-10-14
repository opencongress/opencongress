class Subject < ViewableObject  
  validates_uniqueness_of :term
  #validates_associated :bills

  has_many :bill_subjects
  has_many :bills, :through => :bill_subjects, :order => "bills.introduced DESC"

  has_many :recently_introduced_bills, :class_name => "Bill", :through => :bill_subjects, :source => "bill", :order => "bills.introduced DESC", :limit => 20

  has_many :comments, :as => :commentable

  has_one :issue_stats
  
  has_one :wiki_link


  acts_as_bookmarkable  
 
  @@DISPLAY_OBJECT_NAME = 'Issue'
  
  def display_object_name
    @@DISPLAY_OBJECT_NAME
  end
  
  def atom_id_as_feed
    # dates for issues don't make sense...just use 2007 for now
    "tag:opencongress.org,2007:/issue_feed/#{id}"
  end
  
  def atom_id_as_entry
    "tag:opencongress.org,2007:/issues/#{id}"
  end

  def ident
    "Issue #{id}"
  end

  def title_for_share
    term
  end

  def place_in_battle_royale_100
    b = Subject.find_all_by_most_tracked_for_range(nil, {:limit => 100, :offset => 0})
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
    action_link = "issues"
    if page
      return {:controller => :battle_royale, :action => action_link, :page => page, :issue => self.id, :timeframe => "AllTime"}
    else
      return nil
    end
  end

  def self.find_all_by_most_tracked_for_range(range, options)
    range = 630720000 if range.nil?

    possible_orders = ["bookmark_count_1 asc", "bookmark_count_1 desc", 
                       "total_comments asc", "total_comments desc"]
    logger.info options.to_yaml
    order = options[:order] ||= "bookmark_count_1 desc"
    search = options[:search]

    if possible_orders.include?(order)

      limit = options[:limit] ||= 20
      offset = options[:offset] ||= 0
      not_null_check = order.split(' ').first
      
      if search
      
        find_by_sql(["select subjects.*, rank(fti_names, ?, 1) as tsearch_rank, current_period.bookmark_count_1 as bookmark_count_1,
                     comments_total.total_comments as total_comments,
                     previous_period.bookmark_count_2 as bookmark_count_2 
                     FROM subjects
                     INNER JOIN (select bookmarks.bookmarkable_id  as subject_id_1, count(bookmarks.bookmarkable_id) as bookmark_count_1 
                     FROM bookmarks where created_at > ? AND created_at <= ? group by subject_id_1) current_period ON subjects.id=current_period.subject_id_1
                     LEFT OUTER JOIN (select comments.commentable_id as subject_id_5, count(comments.*) as total_comments 
                     FROM comments WHERE created_at > ? AND comments.commentable_type = 'Subject' GROUP BY comments.commentable_id) comments_total ON subjects.id=comments_total.subject_id_5 
                     LEFT OUTER JOIN (select bookmarks.bookmarkable_id as subject_id_2, count(bookmarks.bookmarkable_id) as bookmark_count_2 
                     FROM bookmarks where created_at > ? AND created_at <= ? group by subject_id_2) previous_period ON subjects.id=previous_period.subject_id_2
                     WHERE #{not_null_check} is not null AND subjects.fti_names @@ to_tsquery('english', ?)
                     ORDER BY #{order} LIMIT #{limit} OFFSET #{offset}", search, range.seconds.ago, Time.now, range.seconds.ago, (range*2).seconds.ago,
                     range.seconds.ago, search])

       else
        find_by_sql(["select subjects.*, current_period.bookmark_count_1 as bookmark_count_1,
                     comments_total.total_comments as total_comments,
                     previous_period.bookmark_count_2 as bookmark_count_2 
                     FROM subjects
                     INNER JOIN (select bookmarks.bookmarkable_id  as subject_id_1, count(bookmarks.bookmarkable_id) as bookmark_count_1 
                     FROM bookmarks where created_at > ? AND created_at <= ? group by subject_id_1) current_period ON subjects.id=current_period.subject_id_1
                     LEFT OUTER JOIN (select comments.commentable_id as subject_id_5, count(comments.*) as total_comments 
                     FROM comments WHERE created_at > ? AND comments.commentable_type = 'Subject' GROUP BY comments.commentable_id) comments_total ON subjects.id=comments_total.subject_id_5 
                     LEFT OUTER JOIN (select bookmarks.bookmarkable_id as subject_id_2, count(bookmarks.bookmarkable_id) as bookmark_count_2 
                     FROM bookmarks where created_at > ? AND created_at <= ? group by subject_id_2) previous_period ON subjects.id=previous_period.subject_id_2
                     WHERE #{not_null_check} is not null order by #{order} LIMIT #{limit} OFFSET #{offset}", range.seconds.ago, Time.now, range.seconds.ago, (range*2).seconds.ago,
                     range.seconds.ago])
        end
     else
       return []
     end
  end  
  def self.count_all_by_most_tracked_for_range(range, options)
    range = 630720000 if range.nil?

    possible_orders = ["bookmark_count_1 asc", "bookmark_count_1 desc", 
                       "total_comments asc", "total_comments desc"]
    logger.info options.to_yaml
    order = options[:order] ||= "bookmark_count_1 desc"
    search = options[:search]

    if possible_orders.include?(order)

      limit = options[:limit] ||= 20
      offset = options[:offset] ||= 0
      not_null_check = order.split(' ').first
      
      if search
      
        count_by_sql(["select count(subjects.*) 
                     FROM subjects
                     INNER JOIN (select bookmarks.bookmarkable_id  as subject_id_1, count(bookmarks.bookmarkable_id) as bookmark_count_1 
                     FROM bookmarks where created_at > ? AND created_at <= ? group by subject_id_1) current_period ON subjects.id=current_period.subject_id_1
                     LEFT OUTER JOIN (select comments.commentable_id as subject_id_5, count(comments.*) as total_comments 
                     FROM comments WHERE created_at > ? AND comments.commentable_type = 'Subject' GROUP BY comments.commentable_id) comments_total ON subjects.id=comments_total.subject_id_5 
                     LEFT OUTER JOIN (select bookmarks.bookmarkable_id as subject_id_2, count(bookmarks.bookmarkable_id) as bookmark_count_2 
                     FROM bookmarks where created_at > ? AND created_at <= ? group by subject_id_2) previous_period ON subjects.id=previous_period.subject_id_2
                     WHERE #{not_null_check} is not null AND subjects.fti_names @@ to_tsquery('english', ?)
                     LIMIT #{limit} OFFSET #{offset}", range.seconds.ago, Time.now, range.seconds.ago, (range*2).seconds.ago,
                     range.seconds.ago, search])

       else
        count_by_sql(["select count(subjects.*) 
                     FROM subjects
                     INNER JOIN (select bookmarks.bookmarkable_id  as subject_id_1, count(bookmarks.bookmarkable_id) as bookmark_count_1 
                     FROM bookmarks where created_at > ? AND created_at <= ? group by subject_id_1) current_period ON subjects.id=current_period.subject_id_1
                     LEFT OUTER JOIN (select comments.commentable_id as subject_id_5, count(comments.*) as total_comments 
                     FROM comments WHERE created_at > ? AND comments.commentable_type = 'Subject' GROUP BY comments.commentable_id) comments_total ON subjects.id=comments_total.subject_id_5 
                     LEFT OUTER JOIN (select bookmarks.bookmarkable_id as subject_id_2, count(bookmarks.bookmarkable_id) as bookmark_count_2 
                     FROM bookmarks where created_at > ? AND created_at <= ? group by subject_id_2) previous_period ON subjects.id=previous_period.subject_id_2
                     WHERE #{not_null_check} is not null LIMIT #{limit} OFFSET #{offset}", range.seconds.ago, Time.now, range.seconds.ago, (range*2).seconds.ago,
                     range.seconds.ago])
        end
     else
       return []
     end
  end

  def self.count_all_by_most_tracked_for_range2(range, options)
    possible_orders = ["bookmark_count_1 asc", "bookmark_count_1 desc", 
                       "total_comments asc", "total_comments desc"]
    logger.info options.to_yaml
    order = options[:order] ||= "bookmark_count_1 desc"
    if possible_orders.include?(order)
      
      limit = options[:limit] ||= 20
      offset = options[:offset] ||= 0
      if order =~ /comments/
        includes = [:comments]
        conditions = ["comments.created_at > ? AND comments.created_at <= ?", range.seconds.ago, Time.now]
      elsif order =~ /bookmark/
        includes = [:bookmarks]
        conditions = ["bookmarks.created_at > ? AND bookmarks.created_at <= ?", range.seconds.ago, Time.now]
      end

      Subject.count(:all, :include => includes, :conditions => conditions)
    else
      return 0
    end    
  end

  def Subject.find_by_most_comments_for_range(range, order = "total_comments")
    not_null_check = "vote_count_1"
    not_null_check = "total_comments" if order == "total_comments"
    Subject.find_by_sql(["select subjects.*, comments_total.comment_count_1 as comment_count FROM subjects 
                      INNER JOIN (select comments.commentable_id as commentable_id, count(comments.commentable_id) as comment_count_1 from comments 
                         WHERE comments.created_at > ? AND comments.commentable_type = 'Subject' GROUP BY comments.commentable_id) comments_total ON comments_total.commentable_id = subjects.id 
                         ORDER BY comment_count DESC LIMIT 30;", range.seconds.ago])
  end
  
  def Subject.random(limit)
    Subject.find_by_sql ["SELECT * FROM (SELECT random(), subjects.* FROM subjects ORDER BY 1) as bs LIMIT ?;", limit]
  end

  def Subject.find_by_first_letter(letter)
    Subject.find(:all, :conditions => ["upper(term) LIKE ?", "#{letter}%"], :order => "term asc")
  end

  def Subject.by_bill_count
    Subject.find(:all, :order => "bill_count desc, term asc")
  end

  def Subject.alphabetical
    Subject.find(:all, :order => "term asc")
  end
  
  def Subject.top20_viewed
    issues = PageView.popular('Subject')
      
    (issues.select {|b| b.stats.entered_top_viewed.nil? }).each do |bv|
      bv.stats.entered_top_viewed = Time.now
      bv.save
    end
    
    (issues.sort { |i1, i2| i2.stats.entered_top_viewed <=> i1.stats.entered_top_viewed })
  end
  
  def Subject.top20_tracked
    Subject.find_by_sql("SELECT subjects.id, subjects.term, COUNT(bookmarks.id) as bookmark_count from subjects inner join bookmarks on subjects.id = bookmarks.bookmarkable_id WHERE bookmarks.bookmarkable_type = 'Subject' group by subjects.id, subjects.term ORDER BY bookmark_count desc LIMIT 20")
    #:all, :joins => "INNER JOIN bookmarks on subjects.id = bookmarks.bookmarkable_id", :conditions => "bookmarks.bookmarkable_type = 'Subject'", :select => "COUNT(bookmarks.id) as bookmark_count, subjects.*", :order => "COUNT(bookmarks.id) DESC", :group => "bookmarks.bookmarkable_id HAVING bookmark_count > 5", :limit => 10)
  end
  def stats
    unless self.issue_stats
      self.issue_stats = IssueStats.new :subject => self
    end
    
    self.issue_stats
  end

  # Returns the number of people tracking this bill, as well as suggestions of what other people
  # tracking this bill are also tracking.
  def tracking_suggestions

    facet_results_hsh = {:my_people_tracked_facet => [], :my_issues_tracked_facet => [], :my_bills_tracked_facet => []}
    my_trackers = 0

    users = User.find_by_solr('[* TO *]', :facets => {:fields => [:my_people_tracked, :my_issues_tracked, :my_bills_tracked], :browse => ["my_issues_tracked:#{self.id}"], :limit => 6, :zeros => false, :sort =>  true}, :limit => 1)
    facets = users.facets

    facet_results_ff = facets['facet_fields']
    if facet_results_ff && facet_results_ff != []
      
      facet_results_ff.each do |fkey, fvalue|
        facet_results = facet_results_ff[fkey]
      
        #solr running through acts as returns as a Hash, or an array if running through tomcat...hence this stuffs
        facet_results_temp_hash = Hash[*facet_results] unless facet_results.class.to_s == "Hash"
        facet_results_temp_hash = facet_results if facet_results.class.to_s == "Hash"

        facet_results_temp_hash.each do |key,value|
          if key == self.id.to_s && fkey == "my_issues_tracked_facet"
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
    
  
  def related_subjects(number)
    SubjectRelation.related(self, number)
  end

  def all_related_subjects()
    SubjectRelation.all_related(self)
  end

  def latest_bills(num, page = 1, congress = DEFAULT_CONGRESS)
    bills.find(:all, :conditions => ['bills.session = ?', congress], 
               :order => 'bills.lastaction DESC').paginate(:per_page => num, :page => page)
  end

  def passed_bills(num, page = 1, congress = DEFAULT_CONGRESS)
    bills.find(:all, :include => :actions, :conditions => ["bills.session=? AND actions.action_type='enacted'", congress], 
               :order => 'actions.datetime DESC').paginate(:per_page => num, :page => page)
  end

  def newest_bills(num, congress = DEFAULT_CONGRESS)
    bills.find(:all, :conditions => ['bills.session = ?', congress], :order => 'bills.introduced DESC', :limit => num);
  end

  def new_bills_since(current_user, congress = DEFAULT_CONGRESS)
    time_since = current_user.previous_login_date
    time_since = 200.days.ago if Rails.env.development?
    
    bills.find(:all, :include => [:actions], 
                     :conditions => ['bills.session = ? AND actions.datetime > ? AND actions.action_type = ?', congress, time_since, 'introduced'], 
                     :order => 'bills.introduced DESC',
                     :limit => 20);
  end
  
  def comments_since(current_user)
    self.comments.count(:id, :conditions => ["created_at > ?", current_user.previous_login_date])
  end
  
  def most_viewed_bills(num = 5, congress = DEFAULT_CONGRESS, seconds = DEFAULT_COUNT_TIME)
    Bill.find_by_sql(["SELECT bills.*, 
                              most_viewed.view_count AS view_count 
                       FROM bills
                       INNER JOIN
                       (SELECT page_views.viewable_id, 
                               count(page_views.viewable_id) AS view_count
                        FROM page_views 
                        WHERE page_views.created_at > ? AND
                              page_views.viewable_type = 'Bill'
                        GROUP BY page_views.viewable_id
                        ORDER BY view_count DESC) most_viewed
                       ON bills.id=most_viewed.viewable_id
                       INNER JOIN bill_subjects ON bill_subjects.bill_id=bills.id
                       WHERE bills.session=? AND bill_subjects.subject_id=?
                       ORDER BY view_count DESC
                       LIMIT ?", 
                      seconds.ago, congress, id, num])
  end

  def latest_major_actions(num)
    Action.find_by_sql( ["SELECT actions.* FROM actions, bill_subjects, bills 
                                    WHERE bill_subjects.subject_id = ? AND 
                                          (actions.action_type = 'introduced' OR
                                           actions.action_type = 'topresident' OR
                                           actions.action_type = 'signed' OR
                                           actions.action_type = 'enacted' OR
                                           actions.action_type = 'vetoed') AND
                                           actions.bill_id = bills.id AND
                                          bill_subjects.bill_id = bills.id
                                    ORDER BY actions.date DESC 
                                    LIMIT #{num}", id])
    #logger.info actions.inspect
    #actions.collect { |a| a.bill }
  end
  
  def before_save
    self.bill_count = id ? BillSubject.count_by_sql("SELECT COUNT(*) FROM bill_subjects INNER JOIN bills ON bills.id=bill_subjects.bill_id WHERE bill_subjects.subject_id=#{id} AND bills.session=#{DEFAULT_CONGRESS}") : 0
  end

  def summary
    #placeholder
  end

  def to_param
    "#{id}_#{url_name}"
  end
  
  def self.full_text_search(q, options = {})
    subjects = Subject.paginate_by_sql(["SELECT subjects.*, rank(fti_names, ?, 1) as tsearch_rank FROM subjects 
                                 WHERE subjects.fti_names @@ to_tsquery('english', ?)
                                 ORDER BY tsearch_rank DESC, term ASC", q, q],
                                :per_page => options[:per_page].nil? ? DEFAULT_SEARCH_PAGE_SIZE : options[:per_page], 
                                :page => options[:page])
    subjects  
  end

  def recent_blogs
    Commentary.find_all_by_commentariable_id_and_commentariable_type_and_is_ok_and_is_news(Subject.find_by_id(5029).recently_introduced_bills.collect {|p| p.id},"Bill",true,false, :order => "created_at DESC", :limit => 10)
  end

  def recent_news
    Commentary.find_all_by_commentariable_id_and_commentariable_type_and_is_ok_and_is_news(Subject.find_by_id(5029).recently_introduced_bills.collect {|p| p.id},"Bill",true,true, :order => "created_at DESC", :limit => 10)
  end

  private
  def url_name
    term.gsub(/[\.\(\)]/, "").gsub(/[-\s]+/, "_").downcase
  end
end
