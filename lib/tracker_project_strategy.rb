class TrackerProjectStrategy

  def initialize(requester)
    @requester = requester
  end

  def create_handler(project)
    ProjectTrackerWorkloadHandler.new(project)
  end

  def create_workload(project)
    workload = PollerWorkload.new
    workload.add_job(:project, project.tracker_project_url)
    workload.add_job(:current_iteration, project.tracker_current_iteration_url)
    workload.add_job(:iterations, project.tracker_iterations_url)
    workload
  end

  def fetch_status(project, url)
    request = @requester.initiate_request(url, head: {'X-TrackerToken' => project.tracker_auth_token})

    request.callback do |client|
      yield PollState::SUCCEEDED, client.response, client.response_header.status
    end

    request.errback do |client|
      yield PollState::FAILED, client.error, -1
    end
  end
end