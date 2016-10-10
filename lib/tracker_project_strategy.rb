class TrackerProjectStrategy

  def initialize(requester)
    @requester = requester
  end

  def create_workload(project)
    workload = PollerWorkload.new
    workload.add_job(:project, project.tracker_project_url)
    workload.add_job(:current_iteration, project.tracker_current_iteration_url)
    workload.add_job(:iterations, project.tracker_iterations_url)
    workload
  end

  def fetch_status(project, url)
    @requester.initiate_request(url, head: {'X-TrackerToken' => project.tracker_auth_token})
  end
end