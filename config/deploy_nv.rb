require 'palmtree/recipes/mongrel_cluster' 
set :runner, "deploy"
set :user, "deploy"
set :application, "opencongress"

set :repository, "svn+ssh://npverni@db.opencongress.org/var/svn/opencongress/branches/nv-political-notebook"
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

default_run_options[:pty] = true
set :deploy_to, "/u/apps/opencongress"

set :use_sudo, true
#false
#set :rails_env, "staging"
set :mongrel_prefix, "#{current_path}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :web, "209.20.73.35"
role :app, "209.20.73.35"
role :db,  "209.20.73.35", :primary => true

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
