class ProjectMonitor.Models.Airbrake extends Backbone.Model
  paramRoot: 'airbrake'

  defaults:
    name: null

class ProjectMonitor.Collections.AirbrakesCollection extends Backbone.Collection
  model: ProjectMonitor.Models.Airbrake
  url: '/airbrakes'
