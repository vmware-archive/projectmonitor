namespace :travis do

  task :setup do
    puts 'Creating config/database.yml'
    system("cp config/database.yml.travis config/database.yml") and puts "... done"

    puts 'Config/auth.yml'
    system("cp config/auth.yml.example config/auth.yml") and puts "... done"
  end

  task :ci do
    require "headless"

    sh 'rake db:create'
    sh 'rake db:migrate'
    sh 'rake db:schema:load RAILS_ENV=test'
    sh 'rake spec'
    sh 'rake jasmine:ci'
  end

end
