class Emailer < ActionMailer::Base

  def send_sponsors(to, from, subject, text, sent_at = Time.now)
    @subject    = subject
    @body       = {:content => text}
    @recipients = to
    @from       = "#{from}"
    @sent_on    = sent_at
    @headers    = {}
  end

  def send_person(to, from, subject, text, sent_at = Time.now)
    @subject    = subject
    @body       = {:content => text}
    @recipients = to
    @from       = "#{from}"
    @sent_on    = sent_at
    @headers    = {}
  end
  
  def feedback(cc, from, subject, message)
    @subject = subject                     
    @recipients = 'writeus@opencongress.org'
    @cc = cc
    @from = from
    @sent_on = Time.now
    @body['message'] = message
  end
  
  def error_snapshot(exception, trace, session, params, env, sent_on = Time.now)
    content_type "text/html" 

    @recipients         = 'oc-errors@lists.ppolitics.org'
    @from               = 'Open Congress Logger <noreply@opencongress.org>'
    @subject            = "Exception in #{env['REQUEST_URI']}" 
    @sent_on            = sent_on
    @body["exception"]  = exception
    @body["trace"]      = trace
    @body["session"]    = session
    @body["params"]     = params
    @body["env"]        = env
  end
  
  def rake_error(exception, message)
    @subject    = "OpenCongress Rake Task Error"
    @recipients = "oc-rake-errors@lists.ppolitics.org"
    @from       = 'Open Congress Rake Tasks <noreply@opencongress.org>'
    @body['exception'] = exception
    @body['message'] = message
    @body['time'] = Time.now
  end
  
  def friend(to, from, subject, url, item_desc, message)
    @subject    = subject
    @recipients = to
    @from       = from
    @headers    = {}
    @body['item_url'] = url
    @body['item_desc'] = item_desc
    @body['message'] = message
    @body['from'] = from
  end
  
  def invite(to, from, url, message)
    @recipients  = to
    @from        = "\"OpenCongress Friends\" <accounts@opencongress.org>"
    @subject     = "#{CGI::escapeHTML(from)} invites you to join OpenCongress"
    @sent_on     = Time.now
    @body[:message] = message
    @body[:url] = url
    @body[:from] = from
  end
end
