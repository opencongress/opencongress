class MailingListObserver < ActiveRecord::Observer
  observe :user

  # The goal of this class is to record changes to columns relating to our e-mail list so
  # that we can keep CiviCRM in sync with OC.
  
  # We don't care about user create because they're not going to be activated when they're created.
  
  def after_update(user)
    # When users become active (activated_at),
    # change their mailing preference (mailing),
    # or changes anything else we store in civicrm,
    # we record the change in a UserAudit.

    # We only save the old value of e-mail address because that's our primary key for
    # accessing the row in civicrm.
    if user.activated_at && user.enabled

      if user.mailing_changed? || user.zipcode_changed? || user.email_changed? || user.activated_at_changed? || user.full_name_changed? || user.district_cache_changed?
        UserAudit.create(
          :user_id => user.id,
          :mailing => user.mailing,
          :email => user.email,
          :email_was => user.email_changed? ? user.email_was : nil,
          :zipcode => user.zipcode,
          :full_name => user.full_name,
          :district => user.district_cache.first
        )
      end

    end
  end

  def after_destroy(user)
    if user.activated_at && user.enabled && user.mailing
      UserAudit.create(
        :user_id => user.id,
        :action => "unsubscribe",
        :email => user.email
      )
    end
  end
end
