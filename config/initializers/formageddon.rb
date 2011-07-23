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
    
    config.reply_domain = 'formageddon.nindy.com'
    config.incoming_email_config = {
      'server' => 'mail.formageddon.nindy.com',
      'username' => 'formageddon@formageddon.nindy.com',
      'password' => 'f0rmagedd0n'
    }
    
    config.tmp_captcha_dir = '/tmp/'
    
  end
end