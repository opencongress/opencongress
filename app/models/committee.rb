class Committee < ActiveRecord::Base
  validates_uniqueness_of :subcommittee_name, :scope => :name

  has_many :committee_people
  has_many :people, :through => :committee_people
  alias :members :people #for convenience, seems to make more sense

  has_many :bill_committees
  has_many :bills, :through => :bill_committees, :order => "bills.lastaction DESC"

  has_many :meetings, :class_name => 'CommitteeMeeting'

  has_many :committee_reports
  has_many :reports, :class_name => 'CommitteeReport'

  has_one :committee_stats

  has_many :comments, :as => :commentable
  has_many :page_views, :as => :viewable

  has_many :bookmarks, :as => :bookmarkable
  
  has_one :wiki_link, :as => "wikiable"


  
  @@DISPLAY_OBJECT_NAME = 'Committee'
  
  #I think this is unfortunately the best way to do this.
  @@HOMEPAGES = {
    "house administration" => "http://www.house.gov/cha/",
    "house agriculture" => "http://agriculture.house.gov/",
    "house appropriations" => "http://www.house.gov/appropriations/",
    "house armed services" => "http://www.house.gov/hasc/",
    "house budget" => "http://www.house.gov/budget/",
    "house education and the workforce" => "http://edworkforce.house.gov",
    "house energy and commerce" => "http://www.house.gov/commerce/",
    "house financial services" => "http://www.house.gov/financialservices/",
    "house government reform" => "http://www.house.gov/reform/",
    "house homeland security" => "http://hsc.house.gov/",
    "house international relations" => "http://www.house.gov/international_relations/",
    "house judiciary" => "http://www.house.gov/judiciary/",
    "house resources" => "http://resourcescommittee.house.gov",
    "house rules" => "http://www.house.gov/rules/",
    "house science" => "http://www.house.gov/science/",
    "house small business" => "http://www.house.gov/smbiz/",
    "house standards of official conduct" => "http://www.house.gov/ethics/",
    "house transportation and infrastructure" => "http://www.house.gov/transportation/",
    "house veterans' affairs" => "http://veterans.house.gov",
    "house ways and means " => "http://waysandmeans.house.gov",
    "house intelligence (permanent select)" => "http://intelligence.house.gov",
    "house select bipartisan committee to investigate the preparation for and response to hurricane katrina" => "http://katrina.house.gov",
    "senate agriculture, nutrition, and forestry" => "http://agriculture.senate.gov/",
    "senate appropriations" => "http://appropriations.senate.gov/","senate armed services" => "http://armed-services.senate.gov/",
    "senate banking, housing, and urban affairs" => "http://banking.senate.gov/",
    "senate budget" => "http://budget.senate.gov/",
    "senate commerce, science, and transportation" => "http://commerce.senate.gov/",
    "senate energy and natural resources" => "http://energy.senate.gov/",
    "senate environment and public works" => "http://epw.senate.gov/",
    "senate finance" => "http://finance.senate.gov/",
    "senate foreign relations" => "http://foreign.senate.gov/",
    "senate health, education, labor, and pensions" => "http://help.senate.gov/",
    "senate homeland security and governmental affairs" => "http://hsgac.senate.gov/",
    "senate judiciary" => "http://judiciary.senate.gov/",
    "senate rules and administration" => "http://rules.senate.gov/",
    "senate small business and entrepreneurship" => "http://sbc.senate.gov/",
    "senate veterans' affairs" => "http://veterans.senate.gov/",
    "senate indian affairs" => "http://indian.senate.gov/",
    "senate select committee on ethics" => "http://ethics.senate.gov/",
    "senate select committee on intelligence" => "http://intelligence.senate.gov/",
    "senate aging (special)" => "http://aging.senate.gov",
    "senate joint committee on printing" => "http://jcp.senate.gov/",
    "senate joint committee on taxation" => "http://www.house.gov/jct",
    "senate joint economic committee" => "http://jec.senate.gov/"}

  @@STOP_WORDS = ["committee", "subcommittee"]

  def display_object_name
    @@DISPLAY_OBJECT_NAME
  end
  
  def atom_id_as_feed
    "tag:opencongress.org,#{CONGRESS_START_DATES[DEFAULT_CONGRESS]}:/committee_feed/#{id}"
  end
  
  def atom_id_as_entry
    # dates for committees are weird, so let use the beginning of each congress session
    "tag:opencongress.org,#{CONGRESS_START_DATES[DEFAULT_CONGRESS]}:/committee/#{id}"
  end
  
  def views(seconds = 0)
    # if the view_count is part of this instance's @attributes use that; otherwise, count
    return @attributes['view_count'] if @attributes['view_count']
    
    if seconds <= 0
      page_views.count
    else
      page_views.count(:conditions => ["created_at > ?", seconds.ago])
    end
  end

  def Committee.random(limit)
    Committee.find_by_sql ["SELECT * FROM (SELECT random(), committees.* FROM committees ORDER BY 1) as bs LIMIT ?;", limit]
  end

  def Committee.find_by_query(committee, subcommittee)
    terms = committee.split.concat(subcommittee.split).uniq.map { |c| c.match(/\W*(\w+)\W*/).captures[0].downcase }
    sub_terms = subcommittee.split.uniq.map { |c| c.match(/\W*(\w+)\W*/).captures[0].downcase }
    query = terms.reject { |t| @@STOP_WORDS.include? t }.join " & "
    if sub_terms.empty?
      cs = Committee.find_by_sql("SELECT * FROM committees WHERE fti_names @@ to_tsquery('english', '#{query}') AND subcommittee_name is null;")
    else
      cs = Committee.find_by_sql("SELECT * FROM committees WHERE fti_names @@ to_tsquery('english', '#{query}');")
    end
    cs
  end


  def Committee.by_chamber(chamber)
    if chamber == 'both'
      Committee.find(:all, :conditions => ['active = ?', true])
    else
      Committee.find(:all, :conditions => ['active = ?', true]).select { |c| c.chamber.match(/#{chamber}/i) }
    end
  end

  def chair
    Person.find :first, :select => "people.*", :include => :committee_people, :order => 'committees_people.id DESC', :conditions => ["(lower(committees_people.role) = 'chair' OR lower(committees_people.role) = 'chairman') AND committees_people.committee_id = ? AND committees_people.session = ?", id, DEFAULT_CONGRESS]
  end 
  
  def vice_chair
    Person.find :first, :select => "people.*", :include => :committee_people, :order => 'committees_people.id DESC', :conditions => ["lower(committees_people.role) = 'vice chairman' AND committees_people.committee_id = ? AND committees_people.session = ?", id, DEFAULT_CONGRESS]
  end
  
  def ranking_member
    Person.find :first, :select => "people.*", :include => :committee_people, :order => 'committees_people.id DESC', :conditions => ["lower(committees_people.role) = 'ranking member' AND committees_people.committee_id = ? AND committees_people.session = ?", id, DEFAULT_CONGRESS]
  end
  
  def Committee.major_committees
    Committee.find(:all, :conditions => ["subcommittee_name IS NULL"], :order => 'name')
  end

  def Committee.find_by_people_name_ci(name)
    Committee.find(:first, :conditions => ["lower(people_name) = ?", name.downcase])
  end

  def Committee.find_by_name_ci(name)
    Committee.find(:first, :conditions => ["lower(name) = ?", name.downcase])
  end

  def Committee.find_by_bill_name_ci(name)
    Committee.find(:first, :conditions => ["lower(bill_name) = ?", name.downcase])
  end

  def to_param
    #For prettier URLS
    "#{id}_#{url_name}"
  end

  def ident
    "Committee #{id}"
  end

  def homepage
    @@HOMEPAGES[name.downcase]
  end
  
  def subcommittees
    Committee.find(:all, :conditions => ["name = ? and subcommittee_name != ''", name], :order => "subcommittee_name asc")
  end
  
  def bills_sponsored(limit)
    ids = Bill.find(:all, :select => "bills.id", :include => :bill_committees, :limit => limit, :order => "lastaction desc", :conditions => ["bills_committees.committee_id = ? AND session = ?", id, DEFAULT_CONGRESS]).map { |b| b.id } 
    bills = (ids.size > 0) ? (Bill.find ids, :include => :bill_titles, :order => 'bills.lastaction DESC') : []
    bills = [bills] if bills.class == Bill
    bills
  end
  
  def latest_major_actions(num)
    Action.find_by_sql( ["SELECT actions.* FROM actions, bills_committees, bills 
                                    WHERE bills_committees.committee_id = ? AND 
                                          (actions.action_type = 'introduced' OR
                                           actions.action_type = 'topresident' OR
                                           actions.action_type = 'signed' OR
                                           actions.action_type = 'enacted' OR
                                           actions.action_type = 'vetoed') AND
                                           actions.bill_id = bills.id AND
                                          bills_committees.bill_id = bills.id
                                    ORDER BY actions.date DESC 
                                    LIMIT #{num}", id])
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
      link = ""
    else
      link = "#{WIKI_BASE_URL}/#{self.wiki_link.name}"
    end
    
    return link

  end

  def proper_name
    if name.nil? || name == ''
      pn = subcommittee_name
    else
      pn = name
      pn += " - #{subcommittee_name}" unless subcommittee_name.nil?
    end
    pn
  end

  def title_for_share
    proper_name
  end
  
  def short_name
    proper_name.sub(/house\s+|senate\s+/i, "")
  end
	
	def main_committee_name
    if name.nil? || name == ''
      pn = subcommittee_name
    else
      pn = name
    end
    pn
  end
	
  def chamber
    if name.match(/^house/i)
      "House"
    elsif name.match(/^senate/i)
      "Senate"
    else
      ""
    end
  end

  def future_meetings
    self.meetings.select { |m| m.meeting_at > Time.now }
  end
  
  def Committee.top20_viewed
    comms = PageView.popular('Committee')
      
    (comms.select {|b| b.stats.entered_top_viewed.nil? }).each do |bv|
      bv.stats.entered_top_viewed = Time.now
      bv.save
    end
    
    (comms.sort { |c1, c2| c2.stats.entered_top_viewed <=> c1.stats.entered_top_viewed })
  end
  
  def stats
    unless self.committee_stats
      self.committee_stats = CommitteeStats.new :committee => self
    end
    
    self.committee_stats
  end
  
  def self.full_text_search(q, options = {})
    Committee.find_by_sql(["SELECT *, rank(fti_names, ?, 1) as tsearch_rank FROM committees 
                           WHERE fti_names @@ to_tsquery('english', ?) order by tsearch_rank DESC;", q, q])
  end

  def new_bills_since(current_user, congress = DEFAULT_CONGRESS)
    time_since = current_user.previous_login_date
    time_since = 200.days.ago if RAILS_ENV == "development"

    bills.find(:all, :include => [:actions],
                     :conditions => ['bills.session = ? AND actions.datetime > ? AND actions.action_type = ?', congress, time_since, 'introduced'],
                     :order => 'bills.introduced DESC',
                     :limit => 20);
  end

  def latest_reports(limit = 5)
    self.committee_reports.find(:all, :order => "reported_at DESC", :conditions => ["reported_at is not null"], :limit => limit)
  end

  def new_reports_since(current_user, congress = DEFAULT_CONGRESS)
    time_since = current_user.previous_login_date
    time_since = 200.days.ago if RAILS_ENV == "development"

    committee_reports.find(:all,
                     :conditions => ['reported_at > ?', time_since],
                     :order => 'reported_at DESC',
                     :limit => 20);
  end

  def comments_since(current_user)
    self.comments.count(:id, :conditions => ["created_at > ?", current_user.previous_login_date])
  end

  
  private
  def url_name
    proper_name.downcase.gsub(/[\s\-]+/, "_").gsub(/[,\'\(\)]/,"")
  end
end
