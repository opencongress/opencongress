set :branch, "production"

role :web, "app1.in.opencongress.org"
role :web, "app2.in.opencongress.org"
role :app, "app1.in.opencongress.org"
role :app, "app2.in.opencongress.org"
role :app, "worker.in.opencongress.org"
role :db,  "app2.in.opencongress.org", :primary => true
role :db, "app1.in.opencongress.org"
