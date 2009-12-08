class RollCallVote < ActiveRecord::Base  
  belongs_to :roll_call
  belongs_to :person
  
  after_create :recount_party_lines

  named_scope :for_state, lambda { |abbrev| {:include => :person, :conditions => {:people => {:state => abbrev} } } }
  
  @@VOTE_FOR_SYMBOL = {
    "+" => "Aye",
    "-" => "Nay",
    "0" => "Abstain",
    "P" => "Present"
  }
  
  def atom_id
    "tag:opencongress.org,#{roll_call.date.strftime("%Y-%m-%d")}:/roll_call_vote/#{id}"
  end
  
  def to_s
    @@VOTE_FOR_SYMBOL[vote].nil? ? vote : @@VOTE_FOR_SYMBOL[vote]
  end
  
  def sort_date
    roll_call.date
  end
  
  def rss_date
    roll_call.date
  end
  
  # can't use a standard comparison for the next two methods because we don't want to count abstains
  def same_vote(other_vote)
    (((vote == "+") && (other_vote.vote == "+")) || ((vote == "-") && (other_vote.vote == "-")))
  end

  def different_vote(other_vote)
    (((vote == "+") && (other_vote.vote == "-")) || ((vote == "-") && (other_vote.vote == "+")))
  end
  
  def recount_party_lines
    self.roll_call.set_party_lines
  end
  
  def self.abstain_count
    RollCallVote.count(:all, :include => [{:roll_call => :bill}], :conditions => ["bills.session = ? AND roll_call_votes.vote = ?", DEFAULT_CONGRESS, "0"], :group => "person_id").sort{|a,b| b[1]<=>a[1]}
  end
  
  def with_party?
    case self.person.party
    when 'Republican'
      if ( self.roll_call.republican_position == true && self.vote == '+' ) || ( self.roll_call.republican_position == false && self.vote == '-' )
        true
      else
        false
      end
    when 'Democrat'
      if ( self.roll_call.democratic_position == true && self.vote == '+' ) || ( self.roll_call.democratic_position == false && self.vote == '-' )
        true
      else
        false
      end
    else
      nil
    end
  end
  
end
