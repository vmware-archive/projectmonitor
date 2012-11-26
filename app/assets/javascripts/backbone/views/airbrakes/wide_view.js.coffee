ProjectMonitor.Views.Airbrakes ||= {}

class ProjectMonitor.Views.Airbrakes.WideView extends Backbone.View
  template: JST["backbone/templates/airbrakes/wide"]

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    @
