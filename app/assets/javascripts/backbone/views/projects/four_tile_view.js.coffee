ProjectMonitor.Views.Projects ||= {}

class ProjectMonitor.Views.Projects.FourTileView extends Backbone.View
  tagName: 'li'

  template: JST["backbone/templates/projects/four_tile"]

  render: ->
    model =
      build_view: (new ProjectMonitor.Views.Builds.SmallView model: @model.get("build")).render().$el.html()
      tracker_view: (new ProjectMonitor.Views.Trackers.SmallView model: @model.get("tracker")).render().$el.html()
      new_relic_view: (new ProjectMonitor.Views.NewRelics.SmallView model: @model.get("new_relic")).render().$el.html()
      airbrake_view: (new ProjectMonitor.Views.Airbrakes.SmallView model: @model.get("airbrake")).render().$el.html()
    $(@el).html(@template(model))
    return this
