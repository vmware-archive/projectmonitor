ProjectMonitor.Views.Projects ||= {}

class ProjectMonitor.Views.Projects.ThreeTileView extends ProjectMonitor.Views.Projects.BaseView
  className: "tile three-tile"
  template: JST["backbone/templates/projects/three_tile"]

  render: ->
    model =
      build_view: (new ProjectMonitor.Views.Builds.TallView model: @model.get("build")).render().$el.html()
      tracker_view: (new ProjectMonitor.Views.Trackers.SmallView model: @model.get("tracker")).render().$el.html()
      new_relic_view: (new ProjectMonitor.Views.NewRelics.SmallView model: @model.get("new_relic")).render().$el.html()
    $(@el).html(@template(model))
    @
