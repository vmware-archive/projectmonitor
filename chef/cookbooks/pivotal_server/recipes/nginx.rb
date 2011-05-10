src_dir = "/usr/local/src/nginx"
install_dir = "/usr/local/nginx"

user "nginx"

{
  "pcre" =>       "6.6-6.el5_6.1",
  "pcre-devel" => "6.6-6.el5_6.1"
}.each do |package_name, version_string|
  ['i386', 'x86_64'].each do |arch_string|
    package package_name do
      action :install
      version "#{version_string}.#{arch_string}"
    end
  end
end

run_unless_marker_file_exists("nginx_1_0_1") do
  execute "download nginx src" do
    command "mkdir -p #{src_dir} && curl -Lsf http://nginx.org/download/nginx-1.0.1.tar.gz |  tar xvz -C#{src_dir} --strip 1"
  end

  execute "configure nginx" do
    command "cd #{src_dir} && ./configure"
  end

  execute "make nginx" do
    command "cd #{src_dir} && make"
  end

  execute "install nginx" do
    command "cd #{src_dir} && make install"
  end
end

execute "nginx owns nginx dirs" do
  command "chown -R nginx /usr/local/nginx"
end

directory "/etc/nginx"

template "/etc/nginx/nginx.conf" do
  source "nginx-conf.erb"
  mode 0744
end

template "/etc/nginx/mime.types" do
  source "nginx-mime-types.erb"
  mode 0744
end

template "/etc/nginx/htpasswd" do
  source "nginx-htaccess.erb"
  mode 0644
end

execute "create daemontools directory" do
  command "mkdir -p /service/nginx"
end

template "/service/nginx/run" do
  source "nginx-run-script.erb"
  mode 0755
end

