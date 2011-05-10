include_recipe "pivotal_server::daemontools"

service_name = "xvfb"

execute "install xvfb" do
  command "yum -y install xorg-x11-server-Xvfb"
end

execute "install firefox" do
  command "yum -y install firefox"
end

execute "make daemontools dir" do
  command "mkdir -p /service/#{service_name}"
end

execute "create run script3" do # srsly! the not_if from mysql was being applied because they had the same name. I kid you not.
  command "echo -e '#!/bin/sh\nexec Xvfb :99 -ac -screen 0 1024x768x16' > /service/#{service_name}/run"
  # not_if "ls /service/#{service_name}/run"
end

execute "make run script executable" do
  command "chmod 755 /service/#{service_name}/run"
end