class BillReferrer < ActiveRecord::Base
  belongs_to :bill
  
  @@NO_FOLLOW = [
    /^\//,
    /www\.google\./,
    /bing\.com/,
    /search\.yahoo/,
    /ask\.com/
  ]
  
  def self.purge
    connection.delete("DELETE FROM bill_referrers WHERE created_at <= '#{2.days.ago.strftime("%Y-%m-%d")}'")
  end
  
  def self.no_follow?(url)
    @@NO_FOLLOW.each do |f|
      return true if f.match(url)
    end
    
    return false
  end
end