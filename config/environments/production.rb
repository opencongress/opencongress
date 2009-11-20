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
  source.starts_with?('/stylesheets') || source.starts_with?('/assets') ? 'http://assets3.opencongress.org' : "http://assets#{rand 4}.opencongress.org"
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

GOVTRACK_DATA_PATH = "/data/govtrack/#{DEFAULT_CONGRESS}"
GOVTRACK_BILLTEXT_PATH = "/data/govtrack/bills.text"
COMMITTEE_REPORTS_PATH = '/data/committee_reports/'
OPENSECRETS_DATA_PATH = '/data/opensecrets/'
OC_BILLTEXT_PATH = '/data/opencongress/bills.text'
GOVTRACK_BILLTEXT_DIFF_PATH = "/data/govtrack/bills.text.cmp"
