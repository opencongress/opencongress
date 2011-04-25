class FacebookPublisher #< Facebooker::Rails::Publisher   
  
  def profile_update(user, fb_user) 
    send_as :profile 
    from fb_user
    recipients fb_user 
    profile render(:partial => 'facebook/profile.fbml', :locals => { :user => user }, :layout => false)
  end   
  
  def bill_to_feed(user, bill, action)
    send_as :user_action
    from user
    story_size ONE_LINE
    data :action_type => action, :bill_url => "http://www.opencongress.org/bill/#{bill.ident}/show", 
         :bill_title => bill.title_full_common
  end
  
  def bill_to_feed_template
    one_line_story_template "{*actor*} is {*action_type*} bill <a href='{*bill_url*}' target='_blank'>{*bill_title*}</a> in the U.S. Congress."
  end
end