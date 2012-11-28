ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.TrackerView extends Backbone.View
  tagName: "article"
  template: JST["backbone/templates/tracker"]

  initialize: (options) ->
    @size = options.size
    @$el.addClass("tracker #{@size}")

  render: ->
    @$el.html(@template($.extend(@model.toJSON(), {size: @size})))
    @
