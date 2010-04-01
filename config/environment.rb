# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
ENV['RAILS_ENV'] ||= 'development'

# Specifies gem version of Rails to use when vendor/rails is not present

RAILS_GEM_VERSION = '2.3.5'

require 'yaml'
require 'ostruct'
#
# A few important constants.
#
API_KEYS = YAML::load(File.open(File.join(File.dirname(__FILE__), 'api_keys.yml')))

# hash to associate a congress to start date
# note: these are not exact dates but correspond to govtrack
CONGRESS_START_DATES = {
  113 => '2013-01-01',
  112 => '2011-01-01',
  111 => '2009-01-01',
  110 => '2007-01-01',
  109 => '2005-01-01',
  108 => '2003-01-01',
  107 => '2001-01-01'
}
AVAILABLE_CONGRESSES = [111, 110, 109]
CURRENT_OPENSECRETS_CYCLE = '2008'
DEFAULT_USERAGENT = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.1) Gecko/20060111 Firefox/1.5.0.1'
DEFAULT_SEARCH_PAGE_SIZE = 10
DEFAULT_CONGRESS = 111
ENV['FACEBOOKER_CALLBACK_PATH'] = '/facebook'
TECHNORATI_API_KEY = API_KEYS['technorati_api_key']


# Ban file
BAN_FILE = '/u/apps/opencongress/shared/files/banned_users.txt'

# URLs you should know about
BASE_URL = 'http://www.opencongress.org/'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem "json"
  config.gem "jammit"

  config.action_controller.session = { :session_key => "_myapp_session", :secret => API_KEYS['app_key'] }

  # Settings in config/environments/* take precedence those specified here

  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :mem_cache_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = :user_observer, :friend_observer

  # Disable delivery errors if you bad email addresses should just be ignored
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.sendmail_settings = {
    :location       => '/usr/sbin/sendmail',
    :arguments      => '-XV -f bounces-main -i -t'
  }

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options

end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

ActiveSupport::Inflector.inflections do |inflect| 
  inflect.uncountable 'gossip' #This seems to make sense to me
end

#
# Plugins you may recognize from TV
#
require 'coerce_ids.rb'
require 'extensions.rb'
require 'simple-rss'
require 'acts_as_taggable'
require 'active_record_fk_hack'
require 'action_controller/integration'
require 'wiki_connection'

# Used across the site for things like "This bill was viewed 30,212 in the last 7 days"
DEFAULT_COUNT_TIME = 7.days

# TODO: Use wiki-internal to get wiki content on production rather
# than going through the proxy server (twice)
WIKI_HOST = 'www.opencongress.org'
WIKI_BASE_URL = "http://#{WIKI_HOST}/wiki"


WillPaginate::ViewHelpers.pagination_options[:renderer] = 'SpanLinkRenderer'      
WillPaginate::ViewHelpers.pagination_options[:previous_label] = 'Previous'
WillPaginate::ViewHelpers.pagination_options[:next_label] = 'Next'
