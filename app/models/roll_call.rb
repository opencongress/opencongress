class RollCall < ActiveRecord::Base
  include ViewableObject
#class RollCall < ViewableObject
  belongs_to :bill
  belongs_to :amendment
  has_one :action
  has_many :roll_call_votes, :include => :person, :order => 'people.lastname'
  
  scope :for_ident, lambda { |ident| {:conditions => ["date_part('year', roll_calls.date) = ? AND roll_calls.where = case ? when 'h' then 'house' else 'senate' end AND roll_calls.number = ?", *Bill.ident(ident)]} }

  with_options :class_name => 'RollCallVote' do |rc|
    rc.has_many :aye_votes, :conditions => "roll_call_votes.vote='+'"
    rc.has_many :nay_votes, :conditions => "roll_call_votes.vote='-'"
    rc.has_many :abstain_votes, :conditions => "roll_call_votes.vote='0'"
  end

  with_options :class_name => 'RollCallVote', :include => :person do |rc|
    rc.has_many :democrat_votes, :conditions => "people.party='Democrat'"
    rc.has_many :democrat_aye_votes, :conditions => "people.party='Democrat' AND roll_call_votes.vote='+'"
    rc.has_many :democrat_nay_votes, :conditions => "people.party='Democrat' AND roll_call_votes.vote='-'"
    rc.has_many :democrat_abstain_votes, :conditions => "people.party='Democrat' AND roll_call_votes.vote='0'"
  
    rc.has_many :republican_votes, :conditions => "people.party='Republican'"
    rc.has_many :republican_aye_votes, :conditions => "people.party='Republican' AND roll_call_votes.vote='+'"
    rc.has_many :republican_nay_votes, :conditions => "people.party='Republican' AND roll_call_votes.vote='-'"
    rc.has_many :republican_abstain_votes, :conditions => "people.party='Republican' AND roll_call_votes.vote='0'"
  end

  @@BILL_PASSAGE_TYPES = [
    'On Passage', 'On Agreeing to the Resolution'
  ]
  
  @@AMDT_PASSAGE_TYPES = [
    'On Agreeing to the Amendment'
  ]

  #  before_save :set_party_lines
  def set_party_lines
    if self.republican_nay_votes.count >= self.republican_aye_votes.count
      self.republican_position = false
    else
      self.republican_position = true
    end
    
    if self.democrat_nay_votes.count >= self.democrat_aye_votes.count
      self.democratic_position = false
    else
      self.democratic_position = true
    end
    self.save
  end

  def atom_id
    "tag:opencongress.org,#{date.strftime("%Y-%m-%d")}:/roll_call/#{id}"
  end

  def self.find_by_ident(ident_string)
    for_ident(ident_string).find(:first)
  end
  
  def self.ident(param_id)
    md = /(\d+)-([sh]?)(\d+)$/.match(canonical_name(param_id))
    md ? md.captures : [nil, nil, nil]
  end

  def self.find_pvs_key_votes(congress = Settings.default_congress)
    find(:all, :include => [:bill, :amendment], :order => 'roll_calls.date DESC',
                           :conditions => ['roll_calls.date > ? AND 
                                          ((roll_calls.roll_type IN (?) AND bills.key_vote_category_id IS NOT NULL) OR
                                           (roll_calls.roll_type IN (?) AND amendments.key_vote_category_id IS NOT NULL))', 
                  OpenCongress::Application::CONGRESS_START_DATES[Settings.default_congress], @@BILL_PASSAGE_TYPES, @@AMDT_PASSAGE_TYPES])
  end
  
  def vote_for_person(person)
    RollCallVote.where(["person_id=? AND roll_call_id=?", person.id, self.id]).first
  end
  
  def vote_url
    "/vote/#{self.date.year}/#{where[0...1]}/#{number}"
  end
    
  def total_votes
    (ayes + nays + abstains + presents)
  end
  
  def key_vote?
    return ((@@BILL_PASSAGE_TYPES.include?(roll_type) and bill and bill.key_vote_category) or
           (@@AMDT_PASSAGE_TYPES.include?(roll_type) and amendment and amendment.key_vote_category))
  end
  
  def key_vote_category_name
    if self.amendment
      self.amendement.key_vote_category.name
    elsif self.bill
      self.bill.key_vote_category.name
    else
      ""
    end
  end
  
  def RollCall.latest_votes_for_unique_bills(num = 3)
    RollCall.find_by_sql("SELECT * FROM roll_calls WHERE id IN 
                          (SELECT max(id) AS roll_id FROM roll_calls
                           WHERE bill_id IS NOT NULL
                           GROUP BY bill_id ORDER BY roll_id DESC LIMIT #{num})
                          AND bill_id IS NOT NULL
                          ORDER BY date DESC;" )
  end
  
  
  def RollCall.latest_roll_call_date_on_govtrack
    response = nil;
    http = Net::HTTP.new("www.govtrack.us")
    http.start do |http|
      request = Net::HTTP::Get.new("/congress/votes.xpd", {"User-Agent" => Settings.scraper_useragent})
      response = http.request(request)
    end
    response.body
    
    doc = Hpricot(response.body)
    DateTime.parse((doc/'table[@style="font-size: 90%"]').search("nobr")[1].inner_html)
  end
  
  def short_identifier
    if self.amendment
       self.amendment.display_number
    else
       self.bill.typenumber
    end        
  end
  
  def chamber
    where.capitalize
  end
  
  def self.vote_together(person1, person2)
     together = RollCall.count_by_sql(["SELECT count(roll_calls.id) from roll_calls INNER JOIN (select * from roll_call_votes WHERE person_id = ? AND vote != '0') person1 on person1.roll_call_id = roll_calls.id
                                                       INNER JOIN (select * from roll_call_votes WHERE person_id = ? AND vote != '0') person2 on person2.roll_call_id = roll_calls.id
                                                       WHERE person1.vote = person2.vote", person1.id, person2.id])
                                                       

     total = RollCall.count_by_sql(["SELECT count(roll_calls.id) from roll_calls INNER JOIN (select * from roll_call_votes WHERE person_id = ? AND vote != '0') person1 on person1.roll_call_id = roll_calls.id
                                                       INNER JOIN (select * from roll_call_votes WHERE person_id = ? AND vote != '0') person2 on person2.roll_call_id = roll_calls.id", 
                                                       person1.id, person2.id])
    return [together,total]
  end
  
end
