namespace "truncate" do
  desc "Truncate Payload Log Entries that are older than a certain date or successful (Default: 3 days ago)"
  task :payload_log_entries => :environment do
    duration = 3.days.ago
    duration_count = PayloadLogEntry.where('created_at < ?', duration).count
    Rails.logger.info "#{'*' * 20}Truncating #{duration_count} Payload Log Entries greater than #{duration.strftime('%D')}...#{'*' * 20}"
    PayloadLogEntry.where('created_at < ?', duration).delete_all

    success_count = PayloadLogEntry.where("status = 'successful'").count
    Rails.logger.info "#{'*' * 20}Truncating #{success_count} Payload Log Entries that were successful...#{'*' * 20}"
    PayloadLogEntry.where("status = 'successful'").delete_all
  end

  desc "Truncate Project Statuses down to a smaller number (Default: 15)"
  task :project_statuses => :environment do
    count = 15

   Project.all.map do |proj|
     latest_statuses = proj.statuses.order('created_at DESC').limit(count)
     proj.statuses.where(['id NOT IN (?)', latest_statuses.collect(&:id)]).delete_all
    end
  end
end
