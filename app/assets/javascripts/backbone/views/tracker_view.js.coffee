ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.TrackerView extends Backbone.View
  className: "tracker"
  tagName: "article"
  template: JST["backbone/templates/tracker"]

  initialize: (options) ->
    @model.on("change", @render, @)

  render: ->
    @$el.html(@template($.extend(@model.toJSON(), {size: @size, normalized_velocities: @model.normalized_velocities()})))
    @
