ProjectMonitor.Views.Builds ||= {}

class ProjectMonitor.Views.Builds.TallView extends Backbone.View
  template: JST["backbone/templates/builds/tall"]

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    @
