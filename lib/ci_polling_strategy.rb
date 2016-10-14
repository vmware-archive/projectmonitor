class CIPollingStrategy
  def initialize(requester)
    @requester = requester
  end

  def create_handler(project)
    ProjectWorkloadHandler.new(project)
  end

  def create_workload(project)
    workload = PollerWorkload.new
    workload.add_job(:feed_url, project.feed_url)
    workload.add_job(:build_status_url, project.build_status_url)
    workload
  end

  def fetch_status(project, url)
    request_options = {}

    if project.auth_username.present?
      request_options[:head] = {'authorization' => [project.auth_username, project.auth_password]}
    end

    if project.accept_mime_types.present?
      headers = request_options[:head] || {}
      request_options[:head] = headers.merge('Accept' => project.accept_mime_types)
    end

    request = @requester.initiate_request(url, request_options)

    request.callback do |client|
      yield PollState::SUCCEEDED, client.response, client.response_header.status
    end

    request.errback do |client|
      yield PollState::FAILED, client.error, -1
    end
  end
end