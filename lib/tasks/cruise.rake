task :cruise do
  sh 'rake setup'
  sh 'rake db:migrate'
  sh 'rake db:schema:load RAILS_ENV=test'
  sh 'rake spec'
  sh 'rake jasmine:ci'
#  `rake setup && rake db:migrate && rake db:schema:load RAILS_ENV=test && rake spec && rake jasmine:ci`
end