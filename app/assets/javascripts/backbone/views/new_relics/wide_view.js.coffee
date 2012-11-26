ProjectMonitor.Views.NewRelics ||= {}

class ProjectMonitor.Views.NewRelics.WideView extends Backbone.View
  template: JST["backbone/templates/new_relics/wide"]

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    @
