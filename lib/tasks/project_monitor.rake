namespace :projectmonitor do
  desc "Run the daemon that updates all the projects"
  task :daemon => :environment do
    ProjectPoller.new.daemonize
  end

  desc 'Start the long running project poller process'
  task :poller => :environment do
    ProjectPoller.new.run
  end

  desc 'Update the status for each active project'
  task :fetch_statuses => :environment do
    if Delayed::Job.present?
      ProjectPoller.new.delay(priority: 0).run_once
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
