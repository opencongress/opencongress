set :application, "opencongress-dev"
set :rails_env, "staging"
set :deploy_to, "/u/apps/opencongress-dev"
role :web, "dev.opencongress.org"
role :app, "dev.opencongress.org"
role :db,  "dev.opencongress.org", :primary => true
