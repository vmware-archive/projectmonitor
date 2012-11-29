ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.TileView extends Backbone.View
  tagName: 'section'
  className: 'tile'

  initialize: (options) ->
    @subviews = options.subviews
    @$el.addClass(['one-tile', 'two-tile', 'three-tile', 'four-tile'][@subviews.length - 1])

  render: ->
    @$el.html("")
    for subview in @subviews
      @$el.append(subview.render().$el)
    @
