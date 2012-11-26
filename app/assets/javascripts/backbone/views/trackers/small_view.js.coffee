ProjectMonitor.Views.Trackers ||= {}

class ProjectMonitor.Views.Trackers.SmallView extends Backbone.View
  template: JST["backbone/templates/trackers/small"]

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    @
