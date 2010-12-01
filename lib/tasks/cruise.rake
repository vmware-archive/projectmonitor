task :cruise do
  `rake setup && rake db:migrate && rake db:schema:load RAILS_ENV=test && rake spec jasmine:ci`
end