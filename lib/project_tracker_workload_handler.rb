class ProjectTrackerWorkloadHandler

  attr_reader :project

  def initialize(project)
    @project = project
  end

  def workload_complete(job_results)
    project_payload = job_results[:project]
    current_iteration_payload = job_results[:current_iteration]
    iterations_payload = job_results[:iterations]

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
