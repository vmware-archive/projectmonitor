ProjectMonitor.Views.Projects ||= {}

class ProjectMonitor.Views.Projects.BaseTileView extends Backbone.View
  tagName: 'section'
  className: 'tile'

  initialize: (options) ->
    @subviews = options.subviews


  render: ->
    @$el.html("")
    for subview in @subviews
      @$el.append(subview.render().$el)
    @
