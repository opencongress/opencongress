require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'lib/extensions'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module OpenCongress
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
    # config.action_mailer.sendmail_settings = {
    #   :location       => '/usr/sbin/sendmail',
    #   :arguments      => '-i'
    # }
    
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    config.active_record.include_root_in_json = false

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :gpasswd]
    
    
    # TODO: Use wiki-internal to get wiki content on production rather
    # than going through the proxy server (twice)

    ENV['FACEBOOKER_CALLBACK_PATH'] = '/facebook'
  
    # following should go in application_settings.yml, but it appears settingslogic
    # does not support hashes
    CONGRESS_START_DATES = {
      113 => '2013-01-01',
      112 => '2011-01-01',
      111 => '2009-01-01',
      110 => '2007-01-01',
      109 => '2005-01-01',
      108 => '2003-01-01',
      107 => '2001-01-01'
    }
    
    require 'ostruct'  
  end
end
