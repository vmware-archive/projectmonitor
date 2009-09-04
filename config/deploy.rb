load_paths << 'vendor/plugins/pivotal_core_bundle/lib/capistrano'

# Pick your strategy according to your version control technology
load_paths.unshift('vendor/plugins/subversion_helper/capistrano')
#load_paths.unshift('vendor/plugins/git_helper/capistrano')

# Set up stages for every file in your config/deploy directory
set :stages, Dir["config/deploy/*"].map {|stage| File.basename(stage, '.rb')}
require 'capistrano/ext/multistage'

set :deploy_via, :remote_cache
set(:rails_env) { stage.to_s }

# This file is defined in both of the version control plugins, and picks the appropriate one
load "framework_for_version_control"

# Deploy tasks to run geminstaller
load "deploy/geminstaller_tasks"

# Tasks to pull/push db locally
load "db_tasks"

task :define_tasks do
  # This setup gets you up on non-Engineyard servers.  Set the :non_engineyard variable in any environment that
  # uses this.  You can list non-engineyard-only tasks by typing 'cap -Snon_engineyard=true -T'
  if exists?(:non_engineyard)
    load "deploy/db_tasks"
    load "deploy/mongrel_cluster_tasks"

    after "deploy:update", "deploy:web:disable"
    after "deploy:update", "deploy:db:backup"
    after "deploy:update", "deploy:geminstaller"
    after "deploy:update", "deploy:migrate"
    after "deploy", "deploy:web:enable"
    after "deploy", "deploy:cleanup"

  # This setup gets you up on EngineYard.  Set the :engineyard variable in any environment that
  # uses this.  You can list EngineYard-only tasks by typing 'cap -Sengineyard=true -T'
  elsif exists?(:engineyard)
    require "eycap/recipes"
    ssh_options[:paranoid] = false
    ssh_options[:forward_agent] = true

    namespace :deploy do
      task :default do
        deploy.long
      end
    end
    before "deploy:geminstaller", "deploy:install_geminstaller"
    after "deploy:symlink", "deploy:geminstaller"
    after "deploy:update_code", "deploy:symlink_configs"
  end
end
stages.each {|stage| after stage, :define_tasks}

# Use these environment variables to get non-engineyard tasks (cap -Snon_engineyard=true -T)
if ENV['COMMON_DEMO'] || ENV["COMMON"] || ENV['MONTGOMERY'] || ENV['NON_ENGINEYARD']
  set :common_demo, true # deprecated, :non_engineyard var is now used as the flag
  set :non_engineyard, true
  define_tasks
end
if ENV['ENGINEYARD'] || ENV['EYCAP'] || ENV['EY']
  set :engineyard, true
  define_tasks
end

namespace :deploy do
  task :crontab, :roles => :app do
    if rails_env == 'local'
      puts "Not running crontab loader during deploy tests, it screws up the internal environment which runs on the same server..."
    elsif rails_env == 'demo'
      puts "crontab loader does not yet work on EY Solo, skipping..."
    else
      run "cd #{current_path} && script/load_crontab #{rails_env}"
    end
  end
end
after "deploy", "deploy:crontab"
