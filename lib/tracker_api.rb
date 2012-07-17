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

  def last_ten_velocities
    done = PivotalTracker::Iteration.done(pt_project).map(&:stories).reverse.take(9)
    current = PivotalTracker::Iteration.current(pt_project).stories.select{|story| story.current_state == "accepted"}

    ([current] + done).map { |stories| stories.map(&:estimate).compact.sum }
  end

  private

  def pt_project
    @pt_project ||= PivotalTracker::Project.find(@project.tracker_project_id)
  end
end
