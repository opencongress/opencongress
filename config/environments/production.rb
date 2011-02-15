# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false


# Use the git revision of this release
RELEASE_NUMBER = %x{cat REVISION | cut -c -7}.rstrip

# Enable serving of images, stylesheets, and javascripts from CloudFront
config.action_controller.asset_host = Proc.new {
   |source, request| "#{request.ssl? ? 'https' : 'http'}://d1f0ywl7f2vxwh.cloudfront.net/r-#{RELEASE_NUMBER}"
}


#
# Caching
#

# Require the new memcache gem (v1.5.0 is what's built into Rails 2.3)
require 'memcache'

config.action_controller.perform_caching = true
config.cache_store = :mem_cache_store, '10.13.219.6:11211', { :namespace => 'opencongress_production' }

if defined?(PhusionPassenger)
    PhusionPassenger.on_event(:starting_worker_process) do |forked|
        if forked
            # We're in smart spawning mode.
            Rails.cache.instance_variable_get(:@data).reset
        else
            # We're in conservative spawning mode. We don't need to do anything.
        end
    end
end

DATA_PATH = "/data"
GOVTRACK_DATA_PATH = "#{DATA_PATH}/govtrack/#{DEFAULT_CONGRESS}"
GOVTRACK_BILLTEXT_PATH = "#{DATA_PATH}/govtrack/bills.text"
COMMITTEE_REPORTS_PATH = "#{DATA_PATH}/committee_reports"
OPENSECRETS_DATA_PATH = "#{DATA_PATH}/opensecrets/"
OC_BILLTEXT_PATH = "#{DATA_PATH}/opencongress/bills.text"
GOVTRACK_BILLTEXT_DIFF_PATH = "#{DATA_PATH}/govtrack/bills.text.cmp"
