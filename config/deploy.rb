#
# This uses the capistrano multistage extension (gem install capistrano-ext) to deploy
# to multiple environments.
#
# Use cap deploy to deploy to production; cap staging deploy to deploy to dev.
#
set :stages, %w(staging production)
set :default_stage, "production"
set :user, "cappy"
set :runner, "cappy"

require 'capistrano/ext/multistage'
require 'bundler/capistrano'

#
# These may be overridden by deploy/staging.rb:
#
set :application, "opencongress"
set :deploy_to, "/u/apps/opencongress"
set :rake, "/opt/rubye/bin/rake"

default_run_options[:pty] = true
set :repository,  "git://github.com/opencongress/opencongress.git"
set :branch, "master"
set :scm, :git
set :deploy_via, :remote_cache

default_run_options[:pty] = true

namespace :deploy do
  desc "Link the images"
  task :link_images do
    run "cp #{deploy_to}/#{shared_dir}/database.yml #{current_release}/config/database.yml"
    run "cp #{deploy_to}/#{shared_dir}/api_keys.yml #{current_release}/config/api_keys.yml"
    run "cp #{deploy_to}/#{shared_dir}/newrelic.yml #{current_release}/config/newrelic.yml"
    run "cp #{deploy_to}/#{shared_dir}/facebooker.yml #{current_release}/config/facebooker.yml"
    run "cp #{deploy_to}/#{shared_dir}/newrelic.yml #{current_release}/config/newrelic.yml"
    run "ln -s #{deploy_to}/#{shared_dir}/states #{current_release}/public/images/states"
    run "ln -s #{deploy_to}/#{shared_dir}/user_images #{current_release}/public/images/users"
    run "ln -s #{deploy_to}/#{shared_dir}/blog #{current_release}/public/images/blog"
    run "ln -s /data/govtrack/109/repstats/images/people #{current_release}/public/images/people"
    run "ln -s /data/govtrack/photos #{current_release}/public/images/photos"
    run "ln -s #{deploy_to}/#{shared_dir}/notebook_items #{current_release}/public/"
  	run "ln -s #{deploy_to}/#{shared_dir}/images #{current_release}/public/images/" 
    run "ln -s #{deploy_to}/#{shared_dir}/files/oc_whats.flv #{current_release}/public/oc_whats.flv"
    run "ln -s #{deploy_to}/#{shared_dir}/files/screencast.mp4 #{current_release}/public/screencast.mp4"
    run "ln -s #{deploy_to}/#{shared_dir}/files/facebook.yml #{current_release}/config/"
#    sudo "chown -R mongrel:admins #{current_release}"
  end

  desc "Compile CSS & JS for public/assets/ (see assets.yml)"
  task :jammit do
    run "cd #{current_release}; /opt/rubye/bin/jammit"

    # For Apache content negotiation with Multiviews, we need to rename .css files to .css.css and .js files to .js.js.
    # They will live alongside .css.gz and .js.gz files and the appropriate file will be served based on Accept-Encoding header.
    run "cd #{current_release}/public/assets; for f in *.css; do mv $f `basename $f .css`.css.css; done; for f in *.js; do mv $f `basename $f .js`.js.js; done"
  end

  desc "Restart Passenger"
  task :restart do
    sudo "touch #{deploy_to}/current/tmp/restart.txt"
  end
end

# Deploy hooks...

#
# Delete all but the last 4 releases:
#
set :keep_releases, 4
after "deploy:update", "deploy:cleanup"
after "deploy:update_code", "deploy:link_images"
after "deploy:update_code", "deploy:jammit"


# HopToad install put this in.  Not sure we need it yet.
# Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
#   $: << File.join(vendored_notifier, 'lib')
# end
# 
# require 'hoptoad_notifier/capistrano'
