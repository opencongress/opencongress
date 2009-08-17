class BounceHandler < ActionMailer::Base

  def receive(email)
    begin
      if email.to_s =~ /Status: 5/i
        handle_permanent_failure(email)
      end
    rescue Exception => e
      logger.info e
      # Rescue all exceptions so that error messages don't get emailed to sender.
      # I log the exception.
    end
  end
  private
  # Status codes starting with 5 are permanent errors
  def handle_permanent_failure(email)
    address = original_to(email)
    if (address)

      user = User.find_by_email(address)
      if user
        u_ml = user.user_mailing_list
        if u_ml
          u_ml.status = UserMailingList::BOUNCED
          u_ml.save
        end
      end
    end
  end

  # Returns the email address of the original recipient, or nil.
  def original_to(email)
    address = nil

    # To email address should be in this form:
    # bounces-main+foo=example.com@yourdomain.com

    match = email.header['x-original-to'].to_s.match(/(.*)+(.*)@(.*)/)
    if (match)
      address = match[1].gsub(/=/, '@').gsub('bounces-main+', '')
    end

    return(address)
  end

end

