class ProjectMonitor.Models.Project extends Backbone.Model
  urlRoot: '/projects'
  paramRoot: 'project'
  timeout: 30000

  initialize: (attributes, options) ->
    @id = attributes.project_id
    @set build: new ProjectMonitor.Models.Build(attributes.build) if attributes.build?
    @set tracker: new ProjectMonitor.Models.Tracker(attributes.tracker) if attributes.tracker?
    @refresh()

  update: (attributes) ->
    @get("build").set(attributes.build) if attributes.build?
    @get("tracker").set(attributes.tracker) if attributes.tracker?

  refresh: ->
    @fetch()
    setTimeout((=> @refresh()), @timeout)
