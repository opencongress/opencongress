require File.dirname(__FILE__) + '/settings'

if defined? Formageddon
  Formageddon.configure do |config|
    config.admin_check_filter = :no_users
    config.user_method = :current_user
    config.sender_user_mapping = { 
      :sender_first_name => :full_name,
      :sender_last_name => :full_name,
      :sender_email => :email,
      :sender_zip5 => :zipcode,
      :sender_state => :state
    }
    
    config.privacy_options = [
      ['Public -- Anyone', 'PUBLIC'], 
      ['Private -- You Only', 'PRIVATE']
    ]
    
    config.reply_domain = Settings.formageddon_reply_domain
    config.incoming_email_config = {
      'server' => Settings.formageddon_server,
      'username' => Settings.formageddon_username,
      'password' => ApiKeys.formageddon_password
    }
    
    config.tmp_captcha_dir = '/tmp/'
    
    config.default_params = {
      "Re" => "issue",
      "SubjectOther" => 'Other',
      "view" => 'N/A',
      "responsereq" => 'yes',
      "newsletter_action" => 'unsubscribe'
    }
    
    
  end
end