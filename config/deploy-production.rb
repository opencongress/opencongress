#require 'palmtree/recipes/mongrel_cluster'


set :application, "opencongress"

#set :repository, "svn+ssh://db.opencongress.org/var/svn/opencongress/trunk/"
#set :repository, "svn+ssh://db.opencongress.org/var/svn/opencongress/branches/maple"
#set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

default_run_options[:pty] = true
set :repository,  "git@github.com:opencongress/opencongress.git"
set :scm, "git"


# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"
default_run_options[:pty] = true
set :deploy_to, "/u/apps/opencongress"
set :rails_env, "production"

set :use_sudo, true
#false
#set :mongrel_prefix, "#{current_path}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :web, "75.126.164.19", :asset_host_syncher => true
role :web, "74.86.203.130"
role :app, "75.126.164.19"
role :app, "74.86.203.130"
role :db,  "75.126.164.19", :primary => true
role :db, "74.86.203.130"

desc "Link the images"
task :link_images do
  run "cp #{deploy_to}/#{shared_dir}/database.yml #{current_release}/config/database.yml"
  run "cp #{deploy_to}/#{shared_dir}/api_keys.yml #{current_release}/config/api_keys.yml"
  run "cp #{deploy_to}/#{shared_dir}/facebooker.yml #{current_release}/config/facebooker.yml"
  run "cp #{deploy_to}/#{shared_dir}/mongrel_cluster.yml #{current_release}/config/mongrel_cluster.yml"
  run "cp #{deploy_to}/#{shared_dir}/files/production.rb #{current_release}/config/environments/production.rb"
  run "cp #{deploy_to}/#{shared_dir}/settings.php #{current_release}/public/forum/conf/settings.php"
  run "cp #{deploy_to}/#{shared_dir}/database.php #{current_release}/public/forum/conf/database.php"
  run "ln -s #{deploy_to}/#{shared_dir}/user_images #{current_release}/public/images/users"
  run "ln -s #{deploy_to}/#{shared_dir}/index #{current_release}/index"
  run "ln -s /data/govtrack/109/repstats/images/people #{current_release}/public/images/people"
  run "ln -s /data/govtrack/photos #{current_release}/public/images/photos"
  run "ln -s #{deploy_to}/#{shared_dir}/notebook_items #{current_release}/public/"
	run "ln -s #{deploy_to}/#{shared_dir}/images #{current_release}/public/images/" 
  run "ln -s #{deploy_to}/#{shared_dir}/files/oc_whats.flv #{current_release}/public/oc_whats.flv"
  run "ln -s #{deploy_to}/#{shared_dir}/files/screencast.mp4 #{current_release}/public/screencast.mp4"
  run "ln -s #{deploy_to}/#{shared_dir}/files/facebooker.yml #{current_release}/config/"
  run "ln -s #{deploy_to}/#{shared_dir}/files/synch_s3_asset_host.yml #{current_release}/config/"
  run "ln -s #{deploy_to}/#{shared_dir}/files/facebook.yml #{current_release}/config/"
  sudo "chown -R mongrel:nogroup #{current_release}"
  sudo "chmod 777 #{current_release}/public/forum/conf/settings.php"
  sudo "chmod -R 777 #{current_release}/public/forum/extensions"
  
#  sudo "touch #{current_release}/tmp/restart.txt"
end

after "link_images", "s3_asset_host:synch_public"

namespace :deploy do

  task :after_symlink do
    link_images
#    s3_asset_host:synch_public
  # ...
  end

  task :restart do
    sudo "touch #{current_release}/tmp/restart.txt"
  end

end
