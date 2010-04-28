namespace :cimonitor do
  desc "Update the status for each active project"
  task :fetch_statuses => :environment do
    StatusFetcher.new.fetch_all
  end

  desc "Send an email notification including any projects that have been red for over one day"
  task :red_over_one_day_notification => :environment  do
    CiMonitorNotifier.send_red_over_one_day_notifications
  end
end