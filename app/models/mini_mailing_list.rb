class MiniMailingList < ActionMailer::Base
  def standard_message(user, bills, people)
     recipients user.email
     from       MINI_MAILER_FROM
     subject    "OpenCongress Tracking Update"
     body[:bills] = bills
     body[:people] = people
     body[:user] = user
  end  

end
