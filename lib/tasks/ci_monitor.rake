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

  task :force_update => :environment do
    print "Doing forced update of all projects..."
    Project.find_each do |project|
      StatusFetcher.retrieve_status_for(project)
      StatusFetcher.retrieve_velocity_for(project)
    end
    puts " done."
  end
end
