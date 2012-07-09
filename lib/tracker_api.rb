require 'pivotal_tracker'

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
    iters = PivotalTracker::Iteration.done(pt_project).reverse.take(10)
    iters.map { |i| i.stories.map(&:estimate).compact.sum }
  end

  private

  def pt_project
    PivotalTracker::Project.find(@project.tracker_project_id)
  end
end
