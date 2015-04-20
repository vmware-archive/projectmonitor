class ProjectStatusesTrimmer
  def self.run(trim_to)
    Project.all.map do |proj|
      latest_statuses = proj.statuses.order('created_at DESC').limit(trim_to)
      proj.statuses.where(['id NOT IN (?)', latest_statuses.collect(&:id)]).delete_all
    end
  end
end