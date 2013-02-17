class ProjectMonitor.Models.Tracker extends Backbone.Model
  paramRoot: 'tracker'

  defaults:
    name: null

  normalized_velocities: ->
    velocities = @get("last_ten_velocities")
    return [] unless velocities && velocities.length > 0
    max_velocity = velocities.reduce (a, b) -> Math.max(a, b)

    ((v/max_velocity) * 100 for v in velocities.reverse())

class ProjectMonitor.Collections.TrackersCollection extends Backbone.Collection
  model: ProjectMonitor.Models.Tracker
  url: '/trackers'
