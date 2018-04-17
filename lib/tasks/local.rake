namespace :local do
  desc "Create configuration files from examples"
    task :copyDbConfig do
      puts 'Creating config/database.yml'
      system("cp config/database.yml.example config/database.yml") and puts "... done"
    end

  desc "Setup db"
    task :setupDb => [:copyDbConfig, 'db:create','db:migrate']

  desc "Start rails app"
    task :startRails do
      puts 'Starting rails app'
      system("rails server -b 0.0.0.0 --port 3000")
    end

  desc "Run spec tests"
    task :test => [:setupDb, :spec]

  desc "Start application"
    task :start => [:setupDb, :startRails]
end
