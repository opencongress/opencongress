# Settings specified here will take precedence over those in config/environment.rb

BASE_URL = 'http://dev.opencongress.org'
WIKI_BASE_URL = 'http://wiki-dev.opencongress.org/wiki'

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.debug_rjs                         = true

MINI_MAILER_FROM = "alert@dev.opencongress.org"

DATA_PATH = "#{RAILS_ROOT}/data"    
GOVTRACK_DATA_PATH = "#{DATA_PATH}/govtrack/#{DEFAULT_CONGRESS}"
GOVTRACK_BILLTEXT_PATH = "#{DATA_PATH}/govtrack/bills.text"
COMMITTEE_REPORTS_PATH = "#{DATA_PATH}/committee_reports"
OPENSECRETS_DATA_PATH = "#{DATA_PATH}/opensecrets/"
OC_BILLTEXT_PATH = "#{DATA_PATH}/opencongress/bills.text"
GOVTRACK_BILLTEXT_DIFF_PATH = "#{DATA_PATH}/govtrack/bills.text.cmp"

