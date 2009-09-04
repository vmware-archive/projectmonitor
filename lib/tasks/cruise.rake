desc "The stuff that cruise will execute.  Modify this one to suit your project."
overriding_task :cruise do
  rake "db:setup"
  rake "testspec"
#  rake "jsunit:test" unless ENV['DISABLE_CI_JSUNIT']
#  rake "selenium:local" unless ENV['DISABLE_CI_SELENIUM']
  # DOn't run deploy tests, because the real internal server is on the CI box, and it screws up the cron jobs.
  # run "cap local deploy:setup deploy -S head=true" unless ENV['DISABLE_CI_DEPLOY']
  Rake::Task["cruise:cut"].invoke
end