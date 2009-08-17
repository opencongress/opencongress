class UserNotifier < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Confirm Your OpenCongress Login'
    @body[:url]  = "#{BASE_URL}account/activate/#{user.activation_code}"
  end

  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = BASE_URL
  end

  def forgot_password(user)
    setup_email(user)
    @subject    += 'Request to change your password'
    @body[:url]  = "#{BASE_URL}account/reset_password/#{user.password_reset_code}"
  end

  def reset_password(user)
    setup_email(user)
    @subject    += 'Your password has been reset'
  end
  
  def comment_warning(user, comment)
    setup_email(user)
    @from = "\"OpenCongress Editors\" <writeus@opencongress.org>"
    @subject += "Warning from OpenCongress re: your comment"
    @body[:comment] = comment
  end

  def friend_notification(friend)
    setup_email(friend.friend)
    @from = "\"OpenCongress Friends\" <friends@opencongress.org>"
    @subject    += "#{CGI::escapeHTML(friend.user.login)} invites you to be Friends on OpenCongress"
    @body[:friend] = friend
  end

  def friend_rejected_notification(friend)
    setup_email(friend.user)
    @from = "\"OpenCongress Friends\" <friends@opencongress.org>"
    @subject  += "#{CGI::escapeHTML(friend.friend.login)} has declined your Friend invitation on OpenCongress"
    @body[:friend] = friend
  end

  def friendship_broken_notification(friend)
    setup_email(friend.user)
    @from = "\"OpenCongress Friends\" <friends@opencongress.org>"
    @subject  += "#{CGI::escapeHTML(friend.friend.login)} has ended your OpenCongress Friendship"
    @body[:friend] = friend
  end

  def friend_confirmed_notification(friend)
    setup_email(friend.user)
    @from = "\"OpenCongress Friends\" <friends@opencongress.org>"
    @subject  += "#{CGI::escapeHTML(friend.friend.login)} has accepted your Friend invitation on OpenCongress!"
    @body[:friend] = friend
  end

  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "\"OpenCongress Login\" <accounts@opencongress.org>"
    @subject     = ""
    @sent_on     = Time.now
    @body[:user] = user
  end
end
