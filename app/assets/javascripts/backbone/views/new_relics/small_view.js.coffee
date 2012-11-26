ProjectMonitor.Views.NewRelics ||= {}

class ProjectMonitor.Views.NewRelics.SmallView extends Backbone.View
  template: JST["backbone/templates/new_relics/small"]

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    @
