# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
ENV['RAILS_ENV'] ||= 'development'

# Specifies gem version of Rails to use when vendor/rails is not present

RAILS_GEM_VERSION = '2.3.2'

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

API_KEYS = YAML::load(File.open("config/api_keys.yml"))

AVAILABLE_CONGRESSES = [111, 110, 109]
CURRENT_OPENSECRETS_CYCLE = '2008'

DEFAULT_USERAGENT = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.1) Gecko/20060111 Firefox/1.5.0.1'
DEFAULT_SEARCH_PAGE_SIZE = 10
DEFAULT_CONGRESS = 111
ENV['FACEBOOKER_CALLBACK_PATH'] = '/facebook'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.logger = Logger.new(config.log_path)#, 10, 1048576)
#  config.gem "mbleigh-acts-as-taggable-on", :source => "http://gems.github.com", :lib => "acts-as-taggable-on"   
#  config.gem "rspec"
config.gem 'rspec',         :lib => 'spec'
  config.gem "cucumber"

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


  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
#  config.action_mailer.server_settings = {
#    :address => 'opencongress.org',
#    :port => 25,
#    :domain => 'localhost'
#  } 

#  config.gem 'mislav-will_paginate', :source => "http://gems.github.com/", :lib => "will_paginate"
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

DEFAULT_COUNT_TIME = 7.days
#API_KEYS = YAML::load(File.open("#{RAILS_ROOT}/config/api_keys.yml"))

require 'coerce_ids.rb'
require 'extensions.rb'
require 'simple-rss'
require 'acts_as_taggable'
require 'memcache'
require 'json'
require 'action_controller/integration'
#Forum.establish_connection "vanilla"

#require 'will_paginate'
WillPaginate::ViewHelpers.pagination_options[:renderer] = 'SpanLinkRenderer'      
WillPaginate::ViewHelpers.pagination_options[:previous_label] = 'Previous'
WillPaginate::ViewHelpers.pagination_options[:next_label] = 'Next'

require 'active_record_fk_hack'
#require 'ar_fix_for_ts'
