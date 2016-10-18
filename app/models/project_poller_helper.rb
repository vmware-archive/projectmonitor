class ProjectPollerHelper

  def initialize(polling_strategy_factory = ProjectPollingStrategyFactory.new, project_poller = ProjectPoller.new)
    @polling_strategy_factory = polling_strategy_factory
    @project_poller = project_poller

    @workloads = {}
  end

  def poll_projects(&all_projects_complete)
    updateable_projects.find_each do |project|
      puts "polling #{project}"
      polling_strategy = @polling_strategy_factory.build_ci_strategy(project)
      workload = find_or_create_workload(project, polling_strategy)
      @project_poller.poll_project(
          project, polling_strategy, workload.job_urls,
          &project_polling_complete(workload, project, polling_strategy, &all_projects_complete))
    end
  end

  def poll_tracker(&all_projects_complete)
    projects_with_tracker.find_each do |project|
      polling_strategy = @polling_strategy_factory.build_tracker_strategy
      workload = find_or_create_workload(project, polling_strategy)
      @project_poller.poll_project(
          project, polling_strategy, workload.job_urls,
          &project_polling_complete(workload, project, polling_strategy, &all_projects_complete))
    end
  end

  def updateable_projects
    Project.updateable
  end

  def projects_with_tracker
    Project.tracker_updateable
  end

  private

  def project_polling_complete(workload, project, polling_strategy, &all_projects_complete)
    lambda do |success_flag, job_results_or_error|
      handler = polling_strategy.create_handler(project)
      if success_flag
        handler.workload_complete(job_results_or_error)
      else
        handler.workload_failed(job_results_or_error)
      end
      finish_workload(project, &all_projects_complete)
    end
  end

  def find_or_create_workload(project, polling_strategy)
    unless @workloads.has_key? project
      workload = polling_strategy.create_workload(project)
      @workloads[project] = workload
    end
    @workloads[project]
  end

  def finish_workload(project, &all_projects_complete)
    @workloads.delete(project)
    all_projects_complete.call if @workloads.empty? && block_given?
  end
end