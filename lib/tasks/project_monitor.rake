namespace :projectmonitor do
  desc 'Start the long running project poller process'
  task :poller => :environment do
    ProjectPollingScheduler.new.run
  end

  desc 'Update the status for each active project'
  task :fetch_statuses => :environment do
    if Delayed::Job.present?
      ProjectPollingScheduler.new.delay(priority: 0).run_once
    end
  end

  task :fetch_statuses_now => :environment do
    ProjectPollingScheduler.new.run_once
  end

  desc 'Export the configuration to a yml file'
  task :export => :environment do |task, args|
    puts ConfigExport.export
  end

  desc 'Import the configuration from a yml file'
  task :import => :environment do |task, args|
    ConfigExport.import STDIN.read
  end

  desc 'Run remove unused tags job'
  task :remove_unused_tags => :environment  do
    RemoveUnusedTags::Job.new.perform
  end

end
