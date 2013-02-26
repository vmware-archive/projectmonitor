ProjectMonitor.Collections ||= {}

class ProjectMonitor.Collections.Projects extends Backbone.Collection
  model: ProjectMonitor.Models.Project
  url: "/projects"
  timeout: 30000

  initialize: (attributes, options) ->
    @refresh()

  refresh: =>
    @fetch()
    setTimeout(@refresh, @timeout)
