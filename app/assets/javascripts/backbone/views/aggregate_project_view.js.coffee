ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.AggregateProjectView extends Backbone.View
  tagName: "li"
  className: "aggregate"
  template: JST["backbone/templates/aggregate_project"]

  initialize: (options) ->
    @model.on("change", @render, @)

  render: ->
    @$el.html(@template(@model.toJSON()))
    @$el.removeClass("offline success failure indeterminate")
    @$el.addClass(@model.get('status'))
    @
