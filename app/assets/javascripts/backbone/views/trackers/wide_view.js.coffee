ProjectMonitor.Views.Trackers ||= {}

class ProjectMonitor.Views.Trackers.WideView extends Backbone.View
  template: JST["backbone/templates/trackers/wide"]

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    @
