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
  
  def formageddon_status_explanation(status)
    if status =~ /SENT/
      "We have confirmed delivery of your letter."
    elsif status =~ /WARNING/
      "We believe your letter has been sent, but cannot confirm delivery at this time."
    else
      "There was an error sending your letter. We are aware of the error and will retry sending when the error has been fixed."
    end
  end
end
