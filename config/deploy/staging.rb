set :application, "opencongress-dev"
set :rails_env, "staging"
set :deploy_to, "/u/apps/opencongress-dev"
set :branch, "master"
role :web, "dev.opencongress.org"
role :app, "dev.opencongress.org"
role :db,  "dev.opencongress.org", :primary => true

namespace :deploy do
  desc "Hook up staging symlinks"
  task :symlinks do
    run "ln -s #{current_release}/public/robots.txt.staging #{current_release}/public/robots.txt"
    run "mv #{current_release}/vendor/plugins/acts_as_solr/solr #{current_release}/vendor/plugins/acts_as_solr/solr-notused"
    run "ln -s #{deploy_to}/#{shared_dir}/solr #{current_release}/vendor/plugins/acts_as_solr/solr"
  end
end

after "deploy:update_code", "deploy:symlinks"

# We can control solr on staging, just not on production because
# for production it's running outside of Rails entirely.
namespace :solr do
  task :start, :roles => :app do
      run "cd #{latest_release} && #{rake} solr:start RAILS_ENV=staging 2>/dev/null"
  end

  task :stop, :roles => :app do
      run "cd #{latest_release} && #{rake} solr:stop RAILS_ENV=staging 2>/dev/null"
  end

  task :restart, :roles => :app do
      solr.stop
  solr.start
  end
end
