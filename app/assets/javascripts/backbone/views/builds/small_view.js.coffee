ProjectMonitor.Views.Builds ||= {}

class ProjectMonitor.Views.Builds.SmallView extends Backbone.View
  template: JST["backbone/templates/builds/small"]

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this
