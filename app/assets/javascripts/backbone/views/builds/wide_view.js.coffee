ProjectMonitor.Views.Builds ||= {}

class ProjectMonitor.Views.Builds.WideView extends Backbone.View
  template: JST["backbone/templates/builds/wide"]

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    @
