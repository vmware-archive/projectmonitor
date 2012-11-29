ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.NewRelicView extends Backbone.View
  className: "new_relic"
  tagName: "article"
  template: JST["backbone/templates/new_relic"]

  render: ->
    @$el.html(@template(@model.toJSON()))
    @
