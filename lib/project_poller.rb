#
# Asynchronous IO (via the Reactor model) can be a little confusing, so a bit
# of an explanation is in order:
#
# This poller basically looks for all projects that need updating, then asks
# the project to build a workload, which is a list of jobs that need to be
# completed. A job is essentially a URL that needs to be fetched.
#
# When the complete list of jobs has been completed, the handler is notified and
# the project is updated. The workload model is used as jobs can be completed
# in any order.
#
class ProjectPoller

  def initialize
    @workloads = {}
    @poll_period = 5
    @connection_timeout = 15
    @inactivity_timeout = 15
    @max_follow_redirects = 10
  end

  def daemonize
    fork do
      ActiveRecord::Base.connection.reconnect!
      run
    end
  end

  def run
    EM.run do
      EM.add_periodic_timer(@poll_period) do
        poll_projects
      end
    end
  end

  def stop
    EM.stop_event_loop
  end

  private

  def poll_projects
    Project.updateable.find_each do |project|
      workload = find_or_create_workload(project)

      workload.unfinished_job_descriptions.each do |job_id, description|
        add_workload_handler(project, workload, job_id, description)
      end
    end
  end

  def add_workload_handler(project, workload, job_id, url)
    connection = EM::HttpRequest.new url, connect_timeout: @connection_timeout, inactivity_timeout: @inactivity_timeout

    get_options = {redirects: @max_follow_redirects}
    if project.auth_username
      get_options[:head] = {'authorization' => [project.auth_username, project.auth_password]}
    end

    request = connection.get get_options

    request.callback do |client|
      workload.store(job_id, client.response)
      remove_workload(project) if workload.complete?
    end

    request.errback do |client|
      workload.failed(client.error)
      remove_workload(project)
    end
  end

  def find_or_create_workload(project)
    @workloads[project] ||= PollerWorkload.new(project.handler)
  end

  def remove_workload(project)
    @workloads.delete(project)
  end

end
