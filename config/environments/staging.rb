# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = false

# Enable serving of images, stylesheets, and javascripts from an asset server.
# Here we serve all stylesheets from the same asset server so that we won't fetch
# the same images twice due to relative URLs in different CSS files.
config.action_controller.asset_host = Proc.new { |source|
  source.starts_with?('/stylesheets') ? 'http://a3.opencongress.org' : "http://a#{rand 5}.opencongress.org"
}

# Disable delivery errors if you bad email addresses should just be ignored
# config.action_mailer.raise_delivery_errors = false

config.cache_store = :mem_cache_store, 'localhost:11211', { :namespace => 'opencongress_staging' }

BASE_URL = 'http://dev.opencongress.org/'

GOVTRACK_BILLTEXT_DIFF_PATH = "/data/govtrack/bills.text.cmp"
OC_BILLTEXT_PATH = "/data/opencongress/bills.text"
COMMITTEE_REPORTS_PATH = '/data/committee_reports/'
CRP_DATA_PATH = '/data/crp'
WIKI_BASE_URL = 'http://wiki-dev.opencongress.org/wiki'

# the following API key is for OpenCongress production use only!
TECHNORATI_API_KEY = API_KEYS['technorati_api_key']

WIKI_BASE_URL = "http://wiki-dev.opencongress.org"
MINI_MAILER_FROM = "alerts@dev.opencongress.org"

