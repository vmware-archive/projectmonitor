ProjectMonitor.Views.Projects ||= {}

class ProjectMonitor.Views.Projects.TwoTileView extends Backbone.View
  template: JST["backbone/templates/projects/two_tile"]

  render: ->
    model =
      build_view: (new ProjectMonitor.Views.Builds.WideView model: @model.get("build")).render().$el.html()
      tracker_view: (new ProjectMonitor.Views.Trackers.WideView model: @model.get("tracker")).render().$el.html()
    $(@el).html(@template(model))
    return this
