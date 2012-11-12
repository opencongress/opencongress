require File.expand_path('../api_keys.rb', __FILE__)

Airbrake.configure do |config|
  config.api_key = ApiKeys.airbrake
end
