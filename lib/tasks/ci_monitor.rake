namespace :cimonitor do
  desc 'Start the project poller'
  task :poller => :environment do
    ProjectPoller.new.run
  end

  desc 'Update the status for each active project'
  task :fetch_statuses => :environment do
    if Delayed::Job.present? && !Delayed::Job.exists?("handler LIKE %!ruby/object:ProjectPoller%")
      ProjectPoller.new.delay(priority: 0, max_run_time: 1.year).run
    end
  end

  desc 'Export the configuration to a yml file'
  task :export => :environment do |task, args|
    puts ConfigExport.export
  end

  desc 'Import the configuration from a yml file'
  task :import => :environment do |task, args|
    ConfigExport.import STDIN.read
  end
end
