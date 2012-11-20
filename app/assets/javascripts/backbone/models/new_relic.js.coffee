class ProjectMonitor.Models.NewRelic extends Backbone.Model
  paramRoot: 'new_relic'

  defaults:
    name: null

class ProjectMonitor.Collections.NewRelicsCollection extends Backbone.Collection
  model: ProjectMonitor.Models.NewRelic
  url: '/new_relics'
