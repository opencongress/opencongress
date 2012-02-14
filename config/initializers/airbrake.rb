require 'config/initializers/api_keys'

Airbrake.configure do |config|
  config.api_key = ApiKeys.airbrake
end
