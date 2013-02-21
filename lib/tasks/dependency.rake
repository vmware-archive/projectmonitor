namespace :dependency do
  task :truncate_old_statuses => :environment do
    duration = 3.days.ago
    entries_count = ExternalDependency.where('created_at < ?', duration).count

    Rails.logger.info "#{'*' * 20}Truncating #{entries_count} External Dependency Entries greater than #{duration.strftime('%D')}...#{'*' * 20}"

    ExternalDependency.where('created_at < ?', duration).delete_all
  end
end
