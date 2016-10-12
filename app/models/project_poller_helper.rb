class ProjectPollerHelper

  def initialize(polling_strategy_factory = ProjectPollingStrategyFactory.new, project_poller = ProjectPoller.new)
    @polling_strategy_factory = polling_strategy_factory
    @project_poller = project_poller

    @workloads = {}
  end

  def poll_projects(&all_projects_complete)
    updateable_projects.find_each do |project|
      polling_strategy = @polling_strategy_factory.build_ci_strategy(project)
      workload = find_or_create_workload(project, polling_strategy)
      project_polling_complete = lambda do
        finish_workload(project, &all_projects_complete)
      end

      @project_poller.poll_project(project, polling_strategy, workload, &project_polling_complete)
    end
  end

  def poll_tracker(&all_projects_complete)
    projects_with_tracker.find_each do |project|
      polling_strategy = @polling_strategy_factory.build_tracker_strategy
      workload = find_or_create_workload(project, polling_strategy)
      project_polling_complete = lambda do
        finish_workload(project, &all_projects_complete)
      end

      @project_poller.poll_project(project, polling_strategy, workload, &project_polling_complete)
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

  def finish_workload(project, &all_projects_complete)
    @workloads.delete(project)
    all_projects_complete.call if @workloads.empty? && block_given?
  end
end