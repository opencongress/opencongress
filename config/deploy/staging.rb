set :application, "opencongress-dev"
set :rails_env, "staging"
set :deploy_to, "/u/apps/opencongress-dev"
role :web, "dev.opencongress.org"
role :app, "dev.opencongress.org"
role :db,  "dev.opencongress.org", :primary => true

namespace :deploy do
  desc "Hook up robots.txt"
  task :robots_txt do
    run "ln -s #{current_release}/public/robots.txt.staging #{current_release}/public/robots.txt"
  end
end


after "deploy:update_code", "deploy:robots_txt"
