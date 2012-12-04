class ProjectMonitor.Models.Project extends Backbone.Model
  paramRoot: 'project'
  timeout: 30000

  initialize: (attributes, options) ->
    @.set build: new ProjectMonitor.Models.Build(attributes.build) if attributes.build?
    @.set tracker: new ProjectMonitor.Models.Tracker(attributes.tracker) if attributes.tracker?
    @.set new_relic: new ProjectMonitor.Models.NewRelic(attributes.new_relic) if attributes.new_relic?
    @.set airbrake: new ProjectMonitor.Models.Airbrake(attributes.airbrake) if attributes.airbrake?

  update: (attributes) ->
    @.get("build").set(attributes.build) if attributes.build?
    @.get("tracker").set(attributes.tracker) if attributes.tracker?

  refresh: ->
    @fetch()
    setTimeout((=> @refresh()), @timeout)
