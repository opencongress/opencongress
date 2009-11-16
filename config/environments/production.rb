# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false

# Enable serving of images, stylesheets, and javascripts from an asset server.
# Here we serve all stylesheets from the same asset server so that we won't fetch
# the same images twice due to relative URLs in different CSS files.
config.action_controller.asset_host = Proc.new { |source|
  source.starts_with?('/stylesheets') || source.starts_with?('/min/css') ? 'http://assets3.opencongress.org' : "http://assets#{rand 4}.opencongress.org"
}

#
# Caching
#

# Require the new memcache gem (v1.5.0 is what's built into Rails 2.3)
require 'memcache'

config.action_controller.perform_caching = true
config.cache_store = :mem_cache_store, '10.13.219.6:11211', { :namespace => 'opencongress_production' }

#
# We'll make a CACHE global for the session cache only
# this will use the new memcache-client gem
#
CACHE = MemCache.new(:namespace => 'opencongress_sessions')
CACHE.servers = '10.13.219.6:11211'

# This is where we deal with Passenger's forking copy-on-write socket sharing
# which normally would cause errors / unexpected behavior
begin
   PhusionPassenger.on_event(:starting_worker_process) do |forked|
     if forked
       # We're in smart spawning mode, so...
       # Close duplicated memcached connections - they will open themselves
       CACHE.reset
       Rails.cache.instance_variable_get(:@data).reset
     end
   end
# In case you're not running under Passenger (i.e. devmode with webrick)
rescue NameError => error
end

ActionController::Base.session_store = :mem_cache_store
ActionController::Base.session = {
  :session_key => '_opencongress_session',
  :cache   => CACHE,
  :expires => 86400,
  :secret  => API_KEYS['oc_session_secret_key']
}

