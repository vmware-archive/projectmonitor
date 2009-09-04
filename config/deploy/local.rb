role :app, "localhost"
role :web, "localhost"
role :db, "localhost", :primary => true
set :use_sudo, false
set :non_engineyard, true
set :no_mongrel_restart, true