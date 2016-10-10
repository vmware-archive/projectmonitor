class ProjectPollerHelper

  def initialize
    @workloads = {}
    @connection_timeout = 60
    @inactivity_timeout = 30
    @max_follow_redirects = 10
    @pending = 0
  end

  def poll_projects(&completion_callback)
    updateable_projects.find_each do |project|
      handler = ProjectWorkloadHandler.new(project)
      workload = find_or_create_workload(project, handler)

      workload.unfinished_job_descriptions.each do |job_id, description|
        request = create_ci_request(project, description)
        add_workload_callbacks(project, workload, job_id, request, handler, &completion_callback) if request
      end
    end
  end

  def poll_tracker(&completion_callback)
    projects_with_tracker.find_each do |project|
      handler = ProjectTrackerWorkloadHandler.new(project)
      workload = find_or_create_workload(project, handler)

      workload.unfinished_job_descriptions.each do |job_id, description|
        request = create_tracker_request(project, description)
        add_workload_callbacks(project, workload, job_id, request, handler, &completion_callback)
      end
    end
  end

  def updateable_projects
    Project.updateable
  end

  def projects_with_tracker
    Project.tracker_updateable
  end

  private

  def find_or_create_workload(project, handler)
    unless @workloads.has_key? project
      workload = PollerWorkload.new
      @workloads[project] = workload
      handler.workload_created(workload)
    end
    @workloads[project]
  end

  def create_tracker_request(project, url)
    create_request(url, head: {'X-TrackerToken' => project.tracker_auth_token})
  end

  def create_ci_request(project, url)
    get_options = {}
    if project.auth_username.present?
      get_options[:head] = {'authorization' => [project.auth_username, project.auth_password]}
    end
    if project.accept_mime_types.present?
      headers = get_options[:head] || {}
      get_options[:head] = headers.merge("Accept" => project.accept_mime_types)
    end

    create_request(url, get_options)
  end

  def create_request(url, options = {})
    url = "http://#{url}" unless /\A\S+:\/\// === url
    begin
      connection = EM::HttpRequest.new url, connect_timeout: @connection_timeout, inactivity_timeout: @inactivity_timeout
      get_options = {redirects: @max_follow_redirects}.merge(options)
      connection.get get_options
    rescue Addressable::URI::InvalidURIError => e
      puts "ERROR parsing URL: \"#{url}\""
    end
  end

  def add_workload_callbacks(project, workload, job_id, request, handler, &completion_callback)
    begin_workload

    request.callback do |client|
      workload.store(job_id, client.response)

      if workload.complete?
        handler.workload_complete(workload)
        remove_workload(project)
      end
      finish_workload(&completion_callback)
    end

    request.errback do |client|
      handler.workload_failed(client.error)
      remove_workload(project)
      finish_workload(&completion_callback)
    end
  end

  def remove_workload(project)
    @workloads.delete(project)
  end

  def begin_workload
    @pending += 1
  end

  def finish_workload(&completion_callback)
    @pending -= 1
    completion_callback.call if @pending == 0 && block_given?
  end
end