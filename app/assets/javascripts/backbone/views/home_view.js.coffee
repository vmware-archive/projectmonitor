ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.HomeView extends Backbone.View
  tagName: "ol"
  className: "projects"
  template: JST["backbone/templates/home"]

  initialize: (options) ->
    @subviews = []
    @addTileView(tile) for tile in @collection.models

    @collection.on 'reset', =>
      for view in @subviews
        view.tearDown()
      @subviews.length = 0
      for model in @collection.models
        @addTileView(model)
      @render()

    @collection.on 'add', (model) =>
      unless model.id in (view.model.id for view in @subviews)
        @addTileView(model)
        @render()

    @collection.on 'remove', (model) =>
      viewsToDelete = (view for view in @subviews when view.model.id == model.id)
      for view in viewsToDelete
        view.tearDown()
        @subviews = (v for v in @subviews when v isnt view)

  addTileView: (model) ->
    if model.get("aggregate")
      view = new ProjectMonitor.Views.AggregateProjectView(model: model)
    else
      view = new ProjectMonitor.Views.ProjectView(model: model)
    @subviews.push(view)
    @registerSubView(view)
    

  render: ->
    @$el.empty()
    @$el.append(subview.render().$el) for subview in @subviews
    @
