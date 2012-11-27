ProjectMonitor.Views.Projects ||= {}

class ProjectMonitor.Views.Projects.BaseTileView extends Backbone.View
  tagName: 'section'
  className: 'tile'
  template: JST["backbone/templates/projects/project"]

  render: ->
    subviews = (subview.render().$el.html() for subview in @model.subviews)
    $(@el).html(@template({subviews}))
    @
