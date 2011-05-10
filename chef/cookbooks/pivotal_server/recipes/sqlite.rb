src_dir = "/usr/local/src/sqlite"
install_dir = "/usr/local/sqlite"

run_unless_marker_file_exists("sqlite_0") do
  execute "download sqlite src" do
    command "mkdir -p #{src_dir} && curl -Lsf http://www.sqlite.org/sqlite-autoconf-3070602.tar.gz |  tar xvz -C#{src_dir} --strip 1"
  end

  execute "configure sqlite" do
    command "cd #{src_dir} && ./configure"
  end

  execute "make sqlite" do
    command "cd #{src_dir} && make"
  end

  execute "install sqlite" do
    command "cd #{src_dir} && make install"
  end
end