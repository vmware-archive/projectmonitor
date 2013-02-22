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

execute "Adding TeamCity to init.d" do
  command "cd #{install_dir}/TeamCity && ./bin/runAll.sh start"
end
