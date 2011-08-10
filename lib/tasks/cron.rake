desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  StatusFetcher.new.fetch_all
  AmazonService.schedule(Time.zone.now)
end
