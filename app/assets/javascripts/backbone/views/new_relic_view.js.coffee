ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.NewRelicView extends Backbone.View
  tagName: "article"
  template: JST["backbone/templates/new_relic"]

  initialize: (options) ->
    @size = options.size
    @$el.addClass("new_relic #{@size}")

  render: ->
    @$el.empty()
    $(@el).html(@template(@model.toJSON(), {size: @size} ))
    @
