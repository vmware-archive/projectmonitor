desc "Truncate Payload Log Entries that are older than a certain date"
task :truncate_ci_server_logs => :environment do
  duration = 3.days.ago
  entries_count = PayloadLogEntry.where('created_at < ?', duration).count
  
  Rails.logger.info "#{'*' * 20}Truncating #{entries_count} Payload Log Entries greater than #{duration.strftime('%D')}...#{'*' * 20}"

  PayloadLogEntry.where('created_at < ?', duration).delete_all
end
