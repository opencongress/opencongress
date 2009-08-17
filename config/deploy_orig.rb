require 'palmtree/recipes/mongrel_cluster'

set :application, "opencongress-dev"

set :repository, "svn+ssh://10.13.219.4/var/svn/opencongress/trunk/"
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"
default_run_options[:pty] = true
set :deploy_to, "/u/apps/opencongress-dev"

set :use_sudo, true
#false
set :rails_env, "staging"
set :mongrel_prefix, "#{current_path}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :web, "www.opencongress.org"
role :app, "www.opencongress.org"
role :db,  "www.opencongress.org", :primary => true

desc "Link the images"
task :link_images do
  run "cp #{deploy_to}/#{shared_dir}/database.yml #{current_release}/config/database.yml"
  run "cp #{deploy_to}/#{shared_dir}/mongrel_cluster.yml #{current_release}/config/mongrel_cluster.yml"
  run "cp #{deploy_to}/#{shared_dir}/settings.php #{current_release}/public/forum/conf/settings.php"
  run "cp #{deploy_to}/#{shared_dir}/database.php #{current_release}/public/forum/conf/database.php"
  run "ln -s #{deploy_to}/#{shared_dir}/user_images #{current_release}/public/images/users"
  run "ln -s #{deploy_to}/#{shared_dir}/index #{current_release}/index"
  run "ln -s #{deploy_to}/#{shared_dir}/wiki #{current_release}/public/wiki"
  run "ln -s /data/govtrack/109/repstats/images/people #{current_release}/public/images/people"
  run "ln -s /data/govtrack/photos #{current_release}/public/images/photos"
  run "ln -s /data/blog #{current_release}/public/images/blog"
  sudo "chown -R mongrel:nogroup #{current_release}"
end


namespace :deploy do

  task :after_symlink do
    link_images
  # ...
  end

end
