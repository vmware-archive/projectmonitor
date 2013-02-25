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
    unless @get("aggregate")
      @get("build").set(attributes.build) if attributes.build?

      if attributes.tracker?
        @set("tracker", new ProjectMonitor.Models.Tracker()) unless @get("tracker")
        @get("tracker").set(attributes.tracker)

  parse: (attributes, xhr) ->
    @update(attributes)
    @

  refresh: ->
    @fetch(error: @handleDestroy)
    setTimeout((=> @refresh()), @timeout)

  handleDestroy: (model, xhr, options) =>
    @destroy()
