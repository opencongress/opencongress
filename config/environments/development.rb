# Settings specified here will take precedence over those in config/environment.rb

BASE_URL = 'http://dev.opencongress.org'

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


### CLOUDFRONT TEST
# Use the git revision of this release
RELEASE_NUMBER = %x{cat REVISION | cut -c -7}.rstrip


# Enable serving of images, stylesheets, and javascripts from CloudFront
config.action_controller.asset_host = Proc.new {
   |source, request| "#{request.ssl? ? 'https' : 'http'}://d1f0ywl7f2vxwh.cloudfront.net/r-#{RELEASE_NUMBER}"
}

#### END CLOUDFRONT TEST