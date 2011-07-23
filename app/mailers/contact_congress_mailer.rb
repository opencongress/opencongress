class ContactCongressMailer < ActionMailer::Base
  default :from => "noreply@opencongress.org"
  
  def reply_received_email(ccl, thread)
    @ccl = ccl
    @member_name = "#{thread.formageddon_recipient.title} #{thread.formageddon_recipient.lastname}"
    mail(:to => ccl.user.email, :subject => "#{@member_name} replied to your letter!")
  end
end
