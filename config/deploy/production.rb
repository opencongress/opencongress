require 'delayed/recipes'

set :branch, "production"
set :delayed_job_server_role, :dj
set :rails_env, "production"

server 'app1.in.opencongress.org', :app, :web, :db
server 'app2.in.opencongress.org', :app, :web, :db, :primary => true
server 'dj.in.opencongress.org', :dj
server 'worker.in.opencongress.org', :app

after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"
