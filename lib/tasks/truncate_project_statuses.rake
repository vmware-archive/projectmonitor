desc "Truncate Project Statuses down to a smaller number"
task :truncate_project_statuses => :environment do
  count = 15
  
  Project.all.map do |proj|
    latest_statuses = proj.statuses.order('created_at DESC').limit(count)
    proj.statuses.where(['id NOT IN (?)', latest_statuses.collect(&:id)]).destroy_all
  end
end

