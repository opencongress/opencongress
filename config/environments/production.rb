# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"
config.action_controller.asset_host = "http://assets%d.opencongress.org"

# Disable delivery errors if you bad email addresses should just be ignored
# config.action_mailer.raise_delivery_errors = false
config.action_mailer.delivery_method = :sendmail
config.action_mailer.sendmail_settings = {
  :location       => '/usr/sbin/sendmail',
  :arguments      => '-XV -f bounces-main -i -t'
}


config.cache_store = :mem_cache_store, '10.13.219.6:11211', { :namespace => 'opencongress_production' }

BASE_URL = 'http://www.opencongress.org/'

GOVTRACK_DATA_PATH = '/data/govtrack/111'
GOVTRACK_BILLTEXT_PATH = "/data/govtrack/bills.text/111"
GOVTRACK_BILLTEXT_DIFF_PATH = "/data/govtrack/bills.text.cmp"
OC_BILLTEXT_PATH = "/data/opencongress/bills.text"
COMMITTEE_REPORTS_PATH = '/data/committee_reports/'
CRP_DATA_PATH = '/data/crp'

# the following API key is for OpenCongress production use only!
TECHNORATI_API_KEY = 'xxx'

# Ban file
BAN_FILE = '/usr/local/apache2/conf/extra/banned_users.txt'

WIKI_BASE = "http://www.opencongress.org"
MINI_MAILER_FROM = "alert@alerts.opencongress.org"
WIKI_URL = 'http://wiki.opencongress.org/wiki'

