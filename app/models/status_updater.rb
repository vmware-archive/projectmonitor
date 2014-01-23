require_relative 'project'
require_relative 'project_status'

class StatusUpdater
  def initialize(max_status: 15)
    @max_statuses = max_status
  end

  def update_project(project, status)
    project.statuses << status

    if project.statuses.count > @max_statuses
      keepers = project.statuses.order('created_at DESC').limit(@max_statuses)
      ProjectStatus.delete_all(['project_id = ? AND id not in (?)', project.id, keepers.map(&:id)]) if keepers.any?
    end
  end
end