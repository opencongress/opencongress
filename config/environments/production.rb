# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"
config.action_controller.asset_host = "http://assets%d.opencongress.org"

#
# Caching
#
require 'memcache'

config.action_controller.perform_caching             = true
config.cache_store = :mem_cache_store, 'localhost:11211', { :namespace => 'opencongress_production' }

ActionController::Base.cache_store = :mem_cache_store, "10.13.219.6"

CACHE = MemCache.new(:namespace => 'opencongress')
CACHE.servers = '10.13.219.6:11211'
ActionController::Base.session = {
  :session_key => '_opencongress_session',
  :cache   => CACHE,
  :expires => 86400,
  :secret  => API_KEYS['oc_session_secret_key']
}

ActionController::Base.session_store = :mem_cache_store
