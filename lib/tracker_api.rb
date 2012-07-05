require 'pivotal_tracker'

class TrackerApi
  def initialize(token)
    @token = token
    PivotalTracker::Client.token = token
  end

  def delivered_stories_count(project_id)
    PivotalTracker::Project.find(project_id)
                             .stories
                             .all(current_state: "delivered")
                               .count
  end

  def current_velocity(project_id)
    PivotalTracker::Project.find(project_id).current_velocity
  end

  def last_ten_velocities(project_id)
    pt_project = PivotalTracker::Project.find(project_id)
    iters = PivotalTracker::Iteration.done(pt_project).reverse.take(10)
    iters.map { |i| i.stories.map(&:estimate).compact.sum }
  end
end
