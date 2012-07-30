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

  desc "Immediately update the status for all active projects"
  task :force_update => :environment do
    print "Doing forced update of all projects..."
    Project.enabled.find_each do |project|
      StatusFetcher.retrieve_status_for(project)
      StatusFetcher.retrieve_velocity_for(project)
    end
    puts " done."
  end

  desc "Export the configuration to a yml file"
  task :export => :environment do |task, args|
    puts ConfigExport.export
  end

  desc "Import the configuration from a yml file"
  task :import => :environment do |task, args|
    ConfigExport.import STDIN.read
  end
end
