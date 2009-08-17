# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_open_flash_chart_2_rails_2.3_session',
  :secret      => '7c9c9965e15ea55e903c39e3e0b63a5a884e70bad919a56f2424dee16a6565f002903b0888958cd7a54fa6c8c281cb4637eccbd0685345407fb5515e37606069'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
