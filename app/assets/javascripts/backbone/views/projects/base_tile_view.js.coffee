ProjectMonitor.Views.Projects ||= {}

class ProjectMonitor.Views.Projects.BaseTileView extends Backbone.View
  tagName: 'section'
  className: 'tile'

  render: ->
    @$el.html("")
    for subview in @model.subviews
      @$el.append(subview.render().$el)
    @
