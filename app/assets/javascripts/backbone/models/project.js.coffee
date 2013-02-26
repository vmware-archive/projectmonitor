class ProjectMonitor.Models.Project extends Backbone.Model
  urlRoot: '/projects'
  paramRoot: 'project'

  initialize: (attributes, options) ->
    @id = attributes.project_id
    @set build: new ProjectMonitor.Models.Build(attributes.build) if attributes.build?
    @set tracker: new ProjectMonitor.Models.Tracker(attributes.tracker) if attributes.tracker?
  
  update: (attributes) ->
    unless @get("aggregate")
      @get("build").set(attributes.build) if attributes.build?

      if attributes.tracker?
        @set("tracker", new ProjectMonitor.Models.Tracker()) unless @get("tracker")
        @get("tracker").set(attributes.tracker)
