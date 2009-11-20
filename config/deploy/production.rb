#
# I dream of stable branches.
#
# set :branch, "stable"

role :web, "75.126.164.19", :asset_host_syncher => true
role :web, "74.86.203.130"
role :app, "75.126.164.19"
role :app, "74.86.203.130"
role :db,  "75.126.164.19", :primary => true
role :db, "74.86.203.130"

desc "Compress stylesheets and javascripts ahead of S3 sync"
task :precache_assets, :roles => :app do
  #root_path    = File.expand_path(File.dirname(__FILE__) + '/..')
  #jammit_path  = Dir["#{root_path}/vendor/gems/jammit-*/bin/jammit"].first
  #yui_lib_path = Dir["#{root_path}/vendor/gems/yui-compressor-*/lib"].first
  #assets_path  = "#{root_path}/public/assets"

  # Precaching assets
  run "cd #{current_release}; jammit"
end

#
# Sync with Amazon S3 asset hosts:
#
before "deploy:symlink", "precache_assets"
before "deploy:symlink", "s3_asset_host:synch_public"
