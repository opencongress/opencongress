# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# New Relic RPM
config.gem "newrelic_rpm"

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false

# Enable serving of images, stylesheets, and javascripts from an asset server.
# Here we serve all stylesheets from the same asset server so that we won't fetch
# the same images twice due to relative URLs in different CSS files.
config.action_controller.asset_host = 'http://d4ias6pyz05za.cloudfront.net'

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
