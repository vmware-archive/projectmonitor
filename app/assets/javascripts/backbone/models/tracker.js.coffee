class ProjectMonitor.Models.Tracker extends Backbone.Model
  paramRoot: 'tracker'

  defaults:
    name: null

class ProjectMonitor.Collections.TrackersCollection extends Backbone.Collection
  model: ProjectMonitor.Models.Tracker
  url: '/trackers'
