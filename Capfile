require 'capistrano/ext/multistage'
require "rvm/capistrano"  # Use the gem, don't unshift RVM onto the load path, that's crazy.

set :rvm_ruby_string, ENV['rvm_ruby_string']
set :rvm_type, :user

set :app_name, :cimonitor
set(:app_dir) { "/var/#{stage}/#{app_name}" }
set :user, "cimonitor-user"
default_run_options[:pty] = true

desc "bootstrap"
task :bootstrap do
  app_user = user
  set :user, "root"
  set :default_shell, "/bin/bash"
  upload "script/bootstrap_server.sh", "/root/bootstrap_server.sh"
  run "chmod a+x /root/bootstrap_server.sh"
  run "APP_USER=#{app_user} /root/bootstrap_server.sh"
end

desc "setup and run chef"
task :chef do
  install_base_gems
  upload_cookbooks
  run_soloist
end

desc "Install gems that are needed for a chef run"
task :install_base_gems do
  run "gem list | grep soloist || gem install soloist --no-rdoc --no-ri"
  run "gem list | grep bundler || gem install bundler --no-rdoc --no-ri"
end

desc "Upload cookbooks"
task :upload_cookbooks do
  run "sudo mkdir -p #{app_dir}"
  run "sudo chown -R #{user} #{app_dir}"
  run "rm #{app_dir}/soloistrc || true"
  run "rm -r #{app_dir}/chef || true"
  upload("soloistrc", "#{app_dir}/soloistrc")
  upload("config/ci.yml", "#{app_dir}/ci.yml")
  upload("chef/", "#{app_dir}/chef/", :via => :scp, :recursive => true)
end

desc "Run soloist"
task :run_soloist do
  run "cd #{app_dir} && PATH=/usr/sbin:$PATH APP_NAME=#{fetch(:app_name)} APP_DIR=#{fetch(:app_dir)} LOG_LEVEL=debug soloist"
end