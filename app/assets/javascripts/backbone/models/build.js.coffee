class ProjectMonitor.Models.Build extends Backbone.Model
  paramRoot: 'build'

  defaults:
    name: null

class ProjectMonitor.Collections.BuildsCollection extends Backbone.Collection
  model: ProjectMonitor.Models.Build
  url: '/builds'
