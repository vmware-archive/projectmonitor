ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.AirbrakeView extends Backbone.View
  className: "airbrake"
  tagName: "article"
  template: JST["backbone/templates/airbrake"]

  render: ->
    @$el.html(@template(@model.toJSON()))
    @
