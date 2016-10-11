class ProjectPollerHelper

  def initialize(polling_strategy_factory = ProjectPollingStrategyFactory.new)
    @polling_strategy_factory = polling_strategy_factory

    @workloads = {}
    @pending = 0
  end

  def poll_projects(&completion_callback)
    updateable_projects.find_each do |project|
      polling_strategy = @polling_strategy_factory.build_ci_strategy(project)
      poll_project(project, polling_strategy, &completion_callback)
    end
  end

  def poll_tracker(&completion_callback)
    projects_with_tracker.find_each do |project|
      polling_strategy = @polling_strategy_factory.build_tracker_strategy
      poll_project(project, polling_strategy, &completion_callback)
    end
  end

  def updateable_projects
    Project.updateable
  end

  def projects_with_tracker
    Project.tracker_updateable
  end

  private

  def poll_project(project, polling_strategy, &completion_callback)
    workload = find_or_create_workload(project, polling_strategy)
    workload.unfinished_job_descriptions.each do |job_id, job_description|
      begin_workload
      polling_strategy.fetch_status(project, job_description) do |polling_status, client_response_or_error|
        handler = polling_strategy.create_handler(project)
        if polling_status == PollState::SUCCEEDED
          workload.store(job_id, client_response_or_error)
          if workload.complete?
            handler.workload_complete(workload)
            finish_workload(project, &completion_callback)
          end
        else # FAILURE
          handler.workload_failed(client_response_or_error)
          finish_workload(project, &completion_callback)
        end
      end
    end
  end

  def find_or_create_workload(project, polling_strategy)
    unless @workloads.has_key? project
      workload = polling_strategy.create_workload(project)
      @workloads[project] = workload
    end
    @workloads[project]
  end

  def begin_workload
    @pending += 1
  end

  def finish_workload(project, &completion_callback)
    @workloads.delete(project)
    @pending -= 1
    completion_callback.call if @pending == 0 && block_given?
  end
end