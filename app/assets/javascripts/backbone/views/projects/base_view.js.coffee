ProjectMonitor.Views.Projects ||= {}

class ProjectMonitor.Views.Projects.BaseView extends Backbone.View
  tagName: 'li'
  className: 'tile'
  template: JST["backbone/templates/projects/project"]

  render: ->
    subviews = (subview.render().$el.html() for subview in @model.subviews)
    $(@el).html(@template({subviews}))
    @
