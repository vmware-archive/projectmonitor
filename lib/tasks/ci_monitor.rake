namespace :cimonitor do
  desc "Update the status for each active project"
  task :fetch_statuses => :environment do
    if Delayed::Job.count.zero?
      puts "Queuing jobs to fetch all statuses..."
      StatusFetcher.fetch_all
    else
      puts "DJ queue is not empty.  Refusing to queue new jobs."
    end
  end

  desc "Send an email notification including any projects that have been red for over one day"
  task :red_over_one_day_notification => :environment  do
    CiMonitorNotifier.send_red_over_one_day_notifications
  end
end
