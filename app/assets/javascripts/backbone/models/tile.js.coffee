class ProjectMonitor.Models.Tile extends Backbone.Model
  paramRoot: 'tile'

  initialize: (attributes) ->
    @.set build: new ProjectMonitor.Models.Build(attributes.build) if attributes.build?
    @.set tracker: new ProjectMonitor.Models.Tracker(attributes.tracker) if attributes.tracker?
    @.set new_relic: new ProjectMonitor.Models.NewRelic(attributes.new_relic) if attributes.new_relic?
    @.set airbrake: new ProjectMonitor.Models.Airbrake(attributes.airbrake) if attributes.airbrake?
