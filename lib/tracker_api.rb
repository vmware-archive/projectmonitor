class TrackerApi
  def initialize(project)
    @project = project
    PivotalTracker::Client.token = @project.tracker_auth_token
  end

  def delivered_stories_count
    pt_project.stories.all(current_state: "delivered").count
  end

  def current_velocity
    pt_project.current_velocity
  end

  def stories_to_accept_count
    iteration_stories.select { |story| story.current_state == "delivered" }.count
  end

  def open_stories_count
    iteration_stories.select { |story| story.current_state == "unstarted" }.count
  end

  def last_ten_velocities
    done = PivotalTracker::Iteration.done(pt_project).map(&:stories).reverse.take(10)

    done.map { |stories| stories.map(&:estimate).compact.sum }
  end

  private

  def pt_project
    @pt_project ||= PivotalTracker::Project.find(@project.tracker_project_id)
  end

  def iteration_stories
    @iteration_stories ||= PivotalTracker::Iteration.current(pt_project).stories
  end
end
