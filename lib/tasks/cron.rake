desc "This task is called by the Heroku cron add-on"
task :cron => :environment do |t, args|
  if Delayed::Job.present?
    StatusFetcher.fetch_all
  end

  AmazonService.schedule(Time.zone.now)
end

task :start_workers, [:worker_count] => :environment do | t, args |
  args.with_defaults(:worker_count => 2)
  exec %Q[script/delayed_job start -n "#{args[:worker_count]}"]
end

task :stop_workers => :environment do  | t, args |
  exec %[script/delayed_job stop]
end
