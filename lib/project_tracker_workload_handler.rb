class ProjectTrackerWorkloadHandler

  attr_reader :project

  def initialize(project)
    @project = project
  end

  def workload_created(workload)
    workload.add_job(:project, project.tracker_project_url)
    workload.add_job(:current_iteration, project.tracker_current_iteration_url)
    workload.add_job(:iterations, project.tracker_iterations_url)
  end

  def workload_complete(workload)
    project_payload = workload.recall(:project)
    current_iteration_payload = workload.recall(:current_iteration)
    iterations_payload = workload.recall(:iterations)

    tracker = TrackerPayloadParser.new(project_payload, current_iteration_payload, iterations_payload)

    project.current_velocity = tracker.current_velocity
    project.last_ten_velocities = tracker.last_ten_velocities
    project.iteration_story_state_counts = tracker.iteration_story_state_counts
    project.tracker_online = true
    project.save!
  end

  def workload_failed(_)
    project.tracker_online = false
    project.save!
  end

end
