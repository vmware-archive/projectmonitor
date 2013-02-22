install_dir = Chef::Config[:file_cache_path]
tar_location = "#{install_dir}/teamcity.tar.gz"

execute "download teamcity" do
  command "mkdir -p #{install_dir} && curl -Lsf http://download-ln.jetbrains.com/teamcity/TeamCity-7.1.4.tar.gz -o #{tar_location}"
  not_if { File.exists?(tar_location) }
end

execute "unpack teamcity" do
  command "cd #{install_dir} && tar xfz #{tar_location} && mkdir -p #{install_dir}/TeamCity/logs"
  not_if { File.exists?("#{install_dir}/TeamCity") }
end

execute "start TeamCity" do
  command "cd #{install_dir}/TeamCity && ./bin/runAll.sh start"
end

package "build-essential"
package "libxslt1-dev"
package "libxml2-dev"
gem_package "mechanize"

cookbook_file "#{Chef::Config[:file_cache_path]}/configure_teamcity.rb" do
  source "configure_teamcity.rb"
end

execute 'configure TeamCity' do
   command "cd #{Chef::Config[:file_cache_path]} && ruby configure_teamcity.rb"
end

execute "stop TeamCity" do
  command "cd #{install_dir}/TeamCity && ./bin/runAll.sh stop"
end

execute "download tcWebHooks" do
  command "cd /home/vagrant/.BuildServer/plugins/ && mkdir -p webhooks && curl -Lsf http://downloads.sourceforge.net/project/tcplugins/tcWebHooks_plugin/tcWebHooks-beta-releases/tcWebHooks-0.7.25.115.jar -o webhooks.jar"
  not_if { File.exists?("/home/vagrant/.BuildServer/plugins/webhooks/webhooks.jar")}
end

execute "start TeamCity" do
  command "cd #{install_dir}/TeamCity && ./bin/runAll.sh start"
end
