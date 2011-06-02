module ContactHelper
  def twitter_share_for_letter(letter)
    "http://twitter.com/home?status=" + 
      u("Wrote my members of #Congress on @opencongress to let them know I'm tracking #USbill #" +
        letter.bill.typenumber) 
  end
end
