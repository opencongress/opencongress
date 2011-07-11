module ContactCongressLettersHelper
  def personal_share_message_for_letter(letter, url)
    u("Wrote my members of #Congress on @opencongress to let them know " +
      "#{letter.disposition == 'tracking' ? "I'm tracking" : "I " + letter.disposition} #USbill #" +
      letter.bill.typenumber.downcase.gsub(/\./, '') + " " + url) 
  end
  
  def generic_share_message_for_letter(letter, url)
    u("A letter to #Congress on @opencongress #{position_clause(letter.disposition)} #USbill #" +
      letter.bill.typenumber.downcase.gsub(/\./, '') + " " + url)
  end
  
  def sponsor_tag(bill, person)
    if bill.sponsor == person
      return "(Sponsor)"
    elsif bill.co_sponsors.include?(person)
      return "(Co-Sponsor)"
    else
      return ""
    end
  end
  
end
