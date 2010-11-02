desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
 StatusFetcher.new.schedule_fetches
end