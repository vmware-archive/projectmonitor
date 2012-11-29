ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.ProjectView extends Backbone.View
  tagName: "li"
  className: "project"

  initialize: (options) ->
    @subviews = []
    @subviews.push(new ProjectMonitor.Views.BuildView(model: new ProjectMonitor.Models.Build(@model.get("build")))) if @model.get("build")
    @subviews.push(new ProjectMonitor.Views.TrackerView(model: new ProjectMonitor.Models.Tracker(@model.get("tracker")))) if @model.get("tracker")
    @subviews.push(new ProjectMonitor.Views.NewRelicView(model: new ProjectMonitor.Models.NewRelic(@model.get("new_relic")))) if @model.get("new_relic")
    @subviews.push(new ProjectMonitor.Views.AirbrakeView(model: new ProjectMonitor.Models.Airbrake(@model.get("airbrake")))) if @model.get("airbrake")

  render: ->
    view = new ProjectMonitor.Views.TileView(subviews: @subviews)
    @$el.html(view.render().$el)
    @
