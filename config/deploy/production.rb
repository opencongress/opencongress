require 'delayed/recipes'

set :branch, "production"
set :delayed_job_server_role, :dj

role :web, "app1.in.opencongress.org"
role :web, "app2.in.opencongress.org"
role :dj, "dj.in.opencongress.org"
role :app, "app1.in.opencongress.org"
role :app, "app2.in.opencongress.org"
role :app, "worker.in.opencongress.org"
role :db,  "app2.in.opencongress.org", :primary => true
role :db, "app1.in.opencongress.org"

after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"
