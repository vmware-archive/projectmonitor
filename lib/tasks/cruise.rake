task :cruise do

  require "headless"

  Rake::Task["spec"].invoke

  sh 'rake setup'
  sh 'rake db:migrate'
  sh 'rake db:schema:load RAILS_ENV=test'
  sh 'rake spec'
  Headless.ly(:display => 42) do |headless|
    begin
      sh 'rake jasmine:ci'
    ensure
      headless.destroy
    end
  end

#  `rake setup && rake db:migrate && rake db:schema:load RAILS_ENV=test && rake spec && rake jasmine:ci`
end