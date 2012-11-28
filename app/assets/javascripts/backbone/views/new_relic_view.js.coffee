ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.NewRelicView extends Backbone.View
  tagName: "article"
  template: JST["backbone/templates/new_relic"]

  initialize: (options) ->
    @$el.addClass("new_relic #{options.size}")

  render: ->
    @$el.html(@template(@model.toJSON()))
    @
