class ProjectPollerHelper

  def initialize
    @workloads = {}
    @pending = 0
    @polling_strategy_factory = ProjectPollingStrategyFactory.new
  end

  def poll_projects(&completion_callback)
    updateable_projects.find_each do |project|
      polling_strategy = @polling_strategy_factory.build_ci_strategy(project)

      workload = find_or_create_workload(project, polling_strategy)
      workload.unfinished_job_descriptions.each do |job_id, job_description|
        request = polling_strategy.fetch_status(project, job_description)
        if request
          handler = ProjectWorkloadHandler.new(project)
          add_workload_callbacks(project, workload, job_id, request, handler, &completion_callback)
        else
          remove_workload(project)
        end
      end
    end
  end

  def poll_tracker(&completion_callback)
    projects_with_tracker.find_each do |project|
      polling_strategy = @polling_strategy_factory.build_tracker_strategy

      workload = find_or_create_workload(project, polling_strategy)
      workload.unfinished_job_descriptions.each do |job_id, job_description|
        request = polling_strategy.fetch_status(project, job_description)
        if request
          handler = ProjectTrackerWorkloadHandler.new(project)
          add_workload_callbacks(project, workload, job_id, request, handler, &completion_callback)
        else
          remove_workload(project)
        end
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

  def find_or_create_workload(project, polling_strategy)
    unless @workloads.has_key? project
      workload = polling_strategy.create_workload(project)
      @workloads[project] = workload
    end
    @workloads[project]
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