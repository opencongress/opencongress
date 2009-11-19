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
task :compress_static, :roles => :web, :only => {:asset_host_syncher => true} do
  # static files in public/ are to be compressed ahead of time so they can sync with S3
  # S3sync will deliver content-encoding headers for files ending .gz, .cssgz, or .jsgz
  run "mkdir -p #{current_release}/public/min"
  run "rm -rf #{current_release}/public/min/*"
  run "cp -r #{current_release}/public/javascripts #{current_release}/public/min/js"
  run "cp -r #{current_release}/public/stylesheets #{current_release}/public/min/css"
  #run "find #{current_release}/public/min -name *.[cj]s* -exec java -jar #{current_release}/bin/yuicompressor.jar {} -o {} \\;"
  #run "find #{current_release}/public/min -name *.[cj]s* -exec gzip -c {} > {}.gz \\;"
end

#
# Sync with Amazon S3 asset hosts:
#
after "deploy:symlink", "compress_static"
after "deploy:symlink", "s3_asset_host:synch_public"
