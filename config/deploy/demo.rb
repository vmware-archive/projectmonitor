set :user, 'pulse'
set :monit_group, 'pulse'
role :app, "pulse-demo.pivotallabs.com"
role :web, "pulse-demo.pivotallabs.com"
role :db, "pulse-demo.pivotallabs.com", :primary => true
set :use_sudo, false
set :deploy_to, "/data/pulse"
set :engineyard, true



