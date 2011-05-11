class ApiKeys < Settingslogic
  source "#{Rails.root}/config/api_keys.yml"
  load!
end