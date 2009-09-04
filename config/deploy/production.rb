role :app, "ci.pivotallabs.com"
role :web, "ci.pivotallabs.com"
role :db, "ci.pivotallabs.com", :primary => true
set :use_sudo, false
set :user, 'pivotal'
set :non_engineyard, true
