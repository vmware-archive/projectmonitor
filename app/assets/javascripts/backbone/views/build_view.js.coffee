ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.BuildView extends Backbone.View
  className: "build"
  tagName: "article"
  template: JST["backbone/templates/build"]

  initialize: (options) ->
    @model.on("change", @render, @)

  render: ->
    @$el.html(@template(@model.toJSON()))
    @$el.removeClass("offline success failure indeterminate")
    @$el.addClass(@model.get('status'))
    @
