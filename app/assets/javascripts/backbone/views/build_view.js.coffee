ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.BuildView extends Backbone.View
  className: "build"
  tagName: "article"
  template: JST["backbone/templates/build"]

  render: ->
    @$el.html(@template(@model.toJSON()))
    @$el.addClass(@model.get('status'))
    @
