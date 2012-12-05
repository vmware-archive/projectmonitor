ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.HomeView extends Backbone.View
  tagName: "ol"
  className: "projects"
  template: JST["backbone/templates/home"]

  initialize: (options) ->
    @subviews = []
    for tile in @collection.models
      if tile.get("aggregate")
        view = new ProjectMonitor.Views.AggregateProjectView(model: tile)
      else
        view = new ProjectMonitor.Views.ProjectView(model: tile)
      @subviews.push(view)
      @registerSubView(view)

  render: ->
    @$el.empty()
    @$el.append(subview.render().$el) for subview in @subviews
    @
