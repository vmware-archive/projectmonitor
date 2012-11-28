ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.BuildView extends Backbone.View
  tagName: "article"
  template: JST["backbone/templates/build"]

  initialize: (options) ->
    @size = options.size
    @$el.addClass("build #{@size}")

  render: ->
    @$el.html(@template($.extend(@model.toJSON(), {size: @size})))
    @$el.addClass(@model.get('status'))
    @
