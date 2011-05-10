ruby_block "install daemontools" do
  block do
    directory = "/package/admin"
    repo = "git://github.com/MikeSofaer/daemontools.git"
    dir_name = "daemontools-0.76"
    FileUtils.mkdir_p directory
    system("cd #{directory} && git clone #{repo} #{dir_name}")
    system("cd #{File.join(directory, dir_name)} && ./package/install")
  end
  not_if "ls /command/svscanboot"
end

execute "make sure daemontools is installed" do
  command "ls /command/svscanboot"
end