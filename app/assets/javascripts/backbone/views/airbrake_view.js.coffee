ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.AirbrakeView extends Backbone.View
  tagName: "article"
  template: JST["backbone/templates/airbrake"]

  initialize: (options) ->
    @$el.addClass("airbrake #{options.size}")

  render: ->
    @$el.html(@template(@model.toJSON()))
    @
