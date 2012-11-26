ProjectMonitor.Views.Builds ||= {}

class ProjectMonitor.Views.Builds.LargeView extends Backbone.View
  template: JST["backbone/templates/builds/large"]

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    @
