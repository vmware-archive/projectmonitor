namespace :db do
  # Read from database.yml to create or drop database user for your project.
  # At the moment it only works for MySQL database.
  # SELECT * FROM mysql.user \G statement to find out MySQL users status

  desc "Create MySQL users based on database.yml"
  task :create_users do
    include DbRakeTasks
    root_password = ask_root_password
    statements = []
    db_config.each do |config|
      username = config[1]["username"]
      password = config[1]["password"]
      database = config[1]["database"]
      host = config[1]["host"]
      if username != 'root' and !user_found?(username, host, root_password)
        statements << "CREATE USER '#{username}'@'#{host}' IDENTIFIED BY '#{password}' ; "
        statements << "GRANT ALL ON #{database}.* TO '#{username}'@'#{host}' ; "
      end
    end

    execute(statements, root_password)
  end

  desc "Drop MySQL users based on database.yml"
  task :drop_users do
    include DbRakeTasks
    root_password = ask_root_password
    statements = []
    db_config.each do |config|
      username = config[1]["username"]
      host = config[1]["host"]
      if username != 'root' and user_found?(username, host, root_password)
        statements << "DROP USER '#{username}'@'#{host}' ; "
      end
    end

    execute(statements, root_password)
  end

end

module DbRakeTasks
  def ask_root_password
    require 'highline/import'
    ask("Please type in MySQL root password:") { |question| question.echo = false}
  end

  def db_config
    YAML.load_file("#{RAILS_ROOT}/config/database.yml")
  end

  def user_found?(username, host, root_password)
    statement = "SELECT concat(User, '@', Host) FROM mysql.user " +
                " WHERE User = '#{username}' AND Host = '#{host}'; "
    result = `mysql -uroot -p#{root_password} -e "#{statement}"`
    exit if $? != 0
    return !result.empty?
  end

  def execute(statements, root_password)
    if !statements.empty?
      system "mysql -uroot -p#{root_password} -e \"#{statements}\""
      if $? == 0
        puts statements.join("\n")
        puts "\nDone.\n"
      end
    else
      puts "Nothing to do.\n"
    end
  end
end
