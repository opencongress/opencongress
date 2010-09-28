require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Opencongress
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
    
    config.active_record.observers = :user_observer, :friend_observer, :mailing_list_observer

    # Disable delivery errors if you bad email addresses should just be ignored
    # config.action_mailer.raise_delivery_errors = false
    config.action_mailer.delivery_method = :sendmail
    config.action_mailer.sendmail_settings = {
      :location       => '/usr/sbin/sendmail',
      :arguments      => '-XV -f bounces-main -i -t'
    }
    
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
    
    
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
    CURRENT_OPENSECRETS_CYCLE = '2010'
    DEFAULT_USERAGENT = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.1) Gecko/20060111 Firefox/1.5.0.1'
    DEFAULT_SEARCH_PAGE_SIZE = 10
    DEFAULT_CONGRESS = 111
    ENV['FACEBOOKER_CALLBACK_PATH'] = '/facebook'
    TECHNORATI_API_KEY = API_KEYS['technorati_api_key']


    # Ban file
    BAN_FILE = '/u/apps/opencongress/shared/files/banned_users.txt'

    # URLs you should know about
    BASE_URL = 'http://www.opencongress.org/'
    
    # Used across the site for things like "This bill was viewed 30,212 in the last 7 days"
    DEFAULT_COUNT_TIME = 7.days

    # TODO: Use wiki-internal to get wiki content on production rather
    # than going through the proxy server (twice)
    WIKI_HOST = 'www.opencongress.org'
    WIKI_BASE_URL = "http://#{WIKI_HOST}/wiki"


    WillPaginate::ViewHelpers.pagination_options[:renderer] = 'SpanLinkRenderer'      
    WillPaginate::ViewHelpers.pagination_options[:previous_label] = 'Previous'
    WillPaginate::ViewHelpers.pagination_options[:next_label] = 'Next'
    
  end
end
