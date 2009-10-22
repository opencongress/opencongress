class RollCall < ActiveRecord::Base
  belongs_to :bill
  belongs_to :amendment
  has_one :action
  has_many :page_views, :as => :viewable
  has_many :roll_call_votes, :include => :person, :order => 'people.lastname'
  has_many :aye_votes, :class_name => 'RollCallVote', :conditions => "roll_call_votes.vote='+'"
  has_many :nay_votes, :class_name => 'RollCallVote', :conditions => "roll_call_votes.vote='-'"
  has_many :abstain_votes, :class_name => 'RollCallVote', :conditions => "roll_call_votes.vote='0'"
  has_many :democrat_votes, :class_name => 'RollCallVote', :include => "person", :conditions => "people.party='Democrat'"
  has_many :democrat_aye_votes, :class_name => 'RollCallVote', :include => "person", :conditions => "people.party='Democrat' AND roll_call_votes.vote='+'"
  has_many :democrat_nay_votes, :class_name => 'RollCallVote', :include => "person", :conditions => "people.party='Democrat' AND roll_call_votes.vote='-'"
  has_many :democrat_abstain_votes, :class_name => 'RollCallVote', :include => "person", :conditions => "people.party='Democrat' AND roll_call_votes.vote='0'"
  
  has_many :republican_votes, :class_name => 'RollCallVote', :include => "person", :conditions => "people.party='Republican'"
  has_many :republican_aye_votes, :class_name => 'RollCallVote', :include => "person", :conditions => "people.party='Republican' AND roll_call_votes.vote='+'"
  has_many :republican_nay_votes, :class_name => 'RollCallVote', :include => "person", :conditions => "people.party='Republican' AND roll_call_votes.vote='-'"
  has_many :republican_abstain_votes, :class_name => 'RollCallVote', :include => "person", :conditions => "people.party='Republican' AND roll_call_votes.vote='0'"

#  before_save :set_party_lines
  def views(seconds = 0)
  # if the view_count is part of this instance's @attributes use that; otherwise, count
  return @attributes['view_count'] if @attributes['view_count']
  
  if seconds <= 0
    page_views.count
  else
    page_views.count(:conditions => ["created_at > ?", seconds.ago])
  end
end

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
  
  def RollCall.find_by_ident(ident_string)
    year, ch, number = Bill.ident ident_string
    chamber = (ch == 's') ? 'senate' : 'house'
    
    RollCall.find(:first, 
                  :conditions => ["date_part('year', roll_calls.date) = ? AND roll_calls.where = ? 
                                   AND roll_calls.number = ?",
                                 year, chamber, number])                               
  end 
  
  def RollCall.ident(param_id)
    md = /(\d+)-([sh]?)(\d+)$/.match(canonical_name(param_id))
    md ? md.captures : [nil, nil, nil]
  end
  
  def vote_for_person(person)
    RollCallVote.find(:first, :conditions => [ "person_id=? AND roll_call_id=?", person.id, self.id])
  end
  
  def vote_url
    "/vote/#{self.date.year}/#{where[0...1]}/#{number}"
  end
    
  #def ayes
  #  aye_votes.size
  #end

  #def nays
  #  nay_votes.size
  #end
  
  #def abstains
  #  abstain_votes.size
  #end
  
  def total_votes
    (ayes + nays + abstains + presents)
  end
  
  def RollCall.latest_votes(num = 3)
    RollCall.find(:all, :order => 'date DESC', :limit => num)
  end
  
  def RollCall.latest_votes_for_unique_bills(num = 3)
    RollCall.find_by_sql("SELECT * FROM roll_calls WHERE date IN 
                          (SELECT max(date) AS roll_date FROM roll_calls
                           WHERE bill_id IS NOT NULL
                           GROUP BY bill_id ORDER BY roll_date DESC LIMIT #{num})
                          AND bill_id IS NOT NULL
                          ORDER BY date DESC;" )
  end
  
  
  def RollCall.latest_roll_call_date_on_govtrack
    response = nil;
    http = Net::HTTP.new("www.govtrack.us")
    http.start do |http|
      request = Net::HTTP::Get.new("/congress/votes.xpd", {"User-Agent" => DEFAULT_USERAGENT})
      response = http.request(request)
    end
    response.body
    
    doc = Hpricot(response.body)
    DateTime.parse((doc/'table[@style="font-size: 90%"]').search("nobr")[1].inner_html)
  end
  
  
  @@DISPLAY_CHAMBER = {
    "house" => "House",
    "senate" => "Senate"
  }
  
  def short_identifier
    if self.amendment
       self.amendment.display_number
    else
       self.bill.title_typenumber_only
    end        
  end
  
  def chamber
    @@DISPLAY_CHAMBER[where]
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
