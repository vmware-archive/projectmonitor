role :app, "pulse.flood.pivotallabs.com"
role :web, "pulse.flood.pivotallabs.com"
role :db, "pulse.flood.pivotallabs.com", :primary => true
set :use_sudo, false
set :user, 'pivotal'
set :non_engineyard, true
