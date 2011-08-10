namespace :amazon do
  desc "Schedules the amazon service"
  task :schedule => :environment do
    AmazonService.schedule(Time.zone.now)
  end
end