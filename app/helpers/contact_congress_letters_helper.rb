module ContactCongressLettersHelper
  def personal_share_message_for_letter(letter, url)
    if letter.contactable_type == 'Bill'
      u("Wrote my members of #Congress on @opencongress to let them know " +
        "#{letter.disposition == 'tracking' ? "I'm tracking" : "I " + letter.disposition} #USbill #" +
        letter.contactable.typenumber.downcase.gsub(/\./, '') + " " + url) 
    elsif letter.contactable_type == 'Subject'
      u("Wrote my members of #Congress on @opencongress about #{letter.contactable.term}" + url) 
    end
  end
  
  def generic_share_message_for_letter(letter, url)
    if letter.contactable_type == 'Bill'
      u("A letter to #Congress on @opencongress #{position_clause(letter.disposition)} #USbill #" +
        letter.contactable.typenumber.downcase.gsub(/\./, '') + " " + url)
    elsif letter.contactable_type == 'Subject'
      u("A letter to #Congress on @opencongress regarding #{letter.contactable.term}" + url)
    end
  end
  
  def sponsor_tag(bill, person)
    if bill.sponsor == person
      return "(Sponsor)"
    elsif bill.co_sponsors.include?(person)
      return "(Co-Sponsor: Yes)"
    else
      return "(Co-sponsor: No)"
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
  
  def letter_info(letter)
    if letter.direction == 'TO_SENDER'
      "This letter was a reply from the office of #{letter.formageddon_thread.formageddon_recipient} on #{letter.created_at.strftime('%B %d, %Y')}."
    else
      "This letter was sent from #{letter.formageddon_thread.formageddon_sender.login} to #{letter.formageddon_thread.formageddon_recipient} on #{letter.created_at.strftime('%B %d, %Y')}."
    end
  end
end
