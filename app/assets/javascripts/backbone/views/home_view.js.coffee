ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.HomeView extends Backbone.View
  tagName: "ol"
  template: JST["backbone/templates/home"]

  initialize: (options) ->
    @subviews = []
    for project in @collection.models
      view = new ProjectMonitor.Views.ProjectView(model: project)
      @subviews.push(view)
      @registerSubView(view)

  render: ->
    @$el.empty()
    @$el.append(subview.render().$el) for subview in @subviews
    @
