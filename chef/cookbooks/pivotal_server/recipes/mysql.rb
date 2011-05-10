include_recipe "pivotal_server::daemontools"

src_dir = "/usr/local/src/mysql"
install_dir = "/usr/local/mysql"
mysql_root_password = "password"
mysql_user_name = "app_user"
mysql_user_password = "password"

{
  "cmake" => "2.6.4-5.el5.2",
  "bison" => "2.3-2.1",
  "ncurses-devel" => "5.5-24.20060715"
}.each do |package_name, version_string|
  package package_name do
    action :install
    version version_string
  end
end

user "mysql"

run_unless_marker_file_exists("mysql_5_5_11") do
  execute "download mysql src" do
    command "mkdir -p #{src_dir} && curl -Lsf http://mysql.he.net/Downloads/MySQL-5.5/mysql-5.5.11.tar.gz |  tar xvz -C#{src_dir} --strip 1"
  end

  execute "cmake" do
    command "cmake ."
    cwd src_dir
  end

  execute "make" do
    command "make install"
    cwd src_dir
  end
  
  execute "mysql owns #{install_dir}/data" do
    command "chown -R mysql #{install_dir}/data"
  end

  execute "install db" do
    command "#{install_dir}/scripts/mysql_install_db --user=mysql"
    cwd install_dir
  end
end

execute "create daemontools directory" do
  command "mkdir -p /service/mysql"
end

execute "create run script" do
  command "echo -e '#!/bin/sh\nexec /command/setuidgid mysql  /usr/local/mysql/bin/mysqld' > /service/mysql/run"
  not_if "ls /service/mysql/run"
end

execute "make run script executable" do
  command "chmod 755 /service/mysql/run"
end

ruby_block "wait for mysql to come up" do
  block do
    Timeout::timeout(60) do
      until system("ls /tmp/mysql.sock")
        sleep 1
      end
    end
  end
end

execute "set the root mysql password" do
  command "#{install_dir}/bin/mysqladmin -uroot password #{mysql_root_password}"
  not_if "#{install_dir}/bin/mysql -uroot -p#{mysql_root_password} -e 'show databases'"
end

execute "create app_user user" do
  command "#{install_dir}/bin/mysql -u root -p#{mysql_root_password} -D mysql -r -B -N -e \"CREATE USER '#{mysql_user_name}'@'localhost'\""
  not_if "#{install_dir}/bin/mysql -u root -p#{mysql_root_password} -D mysql -r -B -N -e \"SELECT * FROM user where User='#{mysql_user_name}' and Host = 'localhost'\" | grep -q #{mysql_user_name}"
end 

execute "set password for app_user" do
  command "#{install_dir}/bin/mysql -u root -p#{mysql_root_password} -D mysql -r -B -N -e \"SET PASSWORD FOR '#{mysql_user_name}'@'localhost' = PASSWORD('#{mysql_user_password}')\""
end

execute "grant user all rights (this maybe isn't a great idea)" do
  command "#{install_dir}/bin/mysql -u root -p#{mysql_root_password} -D mysql -r -B -N -e \"GRANT ALL on *.* to '#{mysql_user_name}'@'localhost'\""
end