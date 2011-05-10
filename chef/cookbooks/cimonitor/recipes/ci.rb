include_recipe "pivotal_server::mysql"
include_recipe "pivotal_server::sqlite"
include_recipe "pivotal_server::libxml_prereqs"
include_recipe "pivotal_server::nginx"
include_recipe "pivotal_ci::jenkins"

username = ENV['SUDO_USER'].strip

raise "CI_CONFIG does not contain a jenkins_dir" unless CI_CONFIG["jenkins_dir"]

execute "make projec#t dir" do
  command "mkdir -p #{CI_CONFIG["jenkins_dir"]}/jobs/cimonitor"
  user username
end

template "#{CI_CONFIG["jenkins_dir"]}/jobs/cimonitor/config.xml" do
  source "jenkins-cimonitor-config.xml.erb"
  owner username
end