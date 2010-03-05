# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = false

# Disable delivery errors if you bad email addresses should just be ignored
# config.action_mailer.raise_delivery_errors = false

config.cache_store = :mem_cache_store, 'localhost:11211', { :namespace => 'opencongress_staging' }

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

BASE_URL = 'http://dev.opencongress.org/'

DATA_PATH = "/data"
GOVTRACK_DATA_PATH = "#{DATA_PATH}/govtrack/#{DEFAULT_CONGRESS}"
GOVTRACK_BILLTEXT_PATH = "#{DATA_PATH}/govtrack/bills.text"
COMMITTEE_REPORTS_PATH = "#{DATA_PATH}/committee_reports"
OPENSECRETS_DATA_PATH = "#{DATA_PATH}/opensecrets/"
OC_BILLTEXT_PATH = "#{DATA_PATH}/opencongress/bills.text"
GOVTRACK_BILLTEXT_DIFF_PATH = "#{DATA_PATH}/govtrack/bills.text.cmp"

# the following API key is for OpenCongress production use only!
TECHNORATI_API_KEY = API_KEYS['technorati_api_key']

MINI_MAILER_FROM = "alerts@dev.opencongress.org"

