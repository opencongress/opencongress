set :branch, "production"

role :web, "75.126.164.19", :asset_host_syncher => true
role :web, "74.86.203.130"
role :app, "75.126.164.19"
role :app, "74.86.203.130"
role :app, "worker.opencongress.org"
role :db,  "75.126.164.19", :primary => true
role :db, "74.86.203.130"


#
# Sync with Amazon S3 asset hosts:
#
before "deploy:symlink", "s3_asset_host:synch_public"



