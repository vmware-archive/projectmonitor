class ConcourseProjectStrategy
  def create_handler(project)
    ProjectWorkloadHandler.new(project)
  end

  def create_workload(project)
    workload = PollerWorkload.new
    workload.add_job(:concourse_project, project)
    workload
  end

  def fetch_status(project, description)

  end
end