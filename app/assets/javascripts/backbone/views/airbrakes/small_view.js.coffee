ProjectMonitor.Views.Airbrakes ||= {}

class ProjectMonitor.Views.Airbrakes.SmallView extends Backbone.View
  template: JST["backbone/templates/airbrakes/small"]

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    @
