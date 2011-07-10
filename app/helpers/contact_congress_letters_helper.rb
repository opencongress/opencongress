module ContactCongressLettersHelper
  def share_message_for_letter(letter, url)
    u("Wrote my members of #Congress on @opencongress to let them know " +
      "#{letter.disposition == 'tracking' ? "I'm tracking" : "I " + letter.disposition} #USbill #" +
      letter.bill.typenumber.downcase.gsub(/\./, '') + " " + url) 
  end
end
