if defined? Formageddon
  Formageddon.configure do |config|
    config.admin_check_filter = :no_users
    config.user_method = :current_user
    config.sender_user_mapping = { 
      :sender_first_name => :full_name,
      :sender_first_name => :full_name,
      :sender_email => :email,
      :sender_zip5 => :zipcode,
      :sender_state => :my_state
    }
  end
end