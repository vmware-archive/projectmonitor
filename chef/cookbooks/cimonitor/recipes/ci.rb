include_recipe "pivotal_server::mysql"
include_recipe "pivotal_server::sqlite"
include_recipe "pivotal_server::libxml_prereqs"
include_recipe "pivotal_server::nginx"
include_recipe "pivotal_ci::jenkins"

username = ENV['SUDO_USER'].strip

raise "CI_CONFIG does not contain a jenkins_dir" unless CI_CONFIG["jenkins_dir"]

execute "make project dir" do
  command "mkdir -p #{CI_CONFIG["jenkins_dir"]}/jobs/projectmonitor"
  user username
end

template "#{CI_CONFIG["jenkins_dir"]}/jobs/projectmonitor/config.xml" do
  source "jenkins-projectmonitor-config.xml.erb"
  owner username
end
