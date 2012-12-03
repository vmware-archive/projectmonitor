ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.TileView extends Backbone.View
  tagName: "li"
  className: "tile"
  template: JST["backbone/templates/tile"]

  initialize: (options) ->
    @subviews = []
    @subviews.push(new ProjectMonitor.Views.BuildView(model: @model.get("build"))) if @model.get("build")
    @subviews.push(new ProjectMonitor.Views.TrackerView(model: @model.get("tracker"))) if @model.get("tracker")
    @subviews.push(new ProjectMonitor.Views.NewRelicView(model: @model.get("new_relic"))) if @model.get("new_relic")
    @subviews.push(new ProjectMonitor.Views.AirbrakeView(model: @model.get("airbrake"))) if @model.get("airbrake")
    @.registerSubView(subview) for subview in @subviews
    @$el.data(project_id: @model.get("project_id"))

  render: ->
    @$el.html(@template({}))
    $section = @$el.find("section")
    $section.addClass(['one-tile', 'two-tile', 'three-tile', 'four-tile'][@subviews.length - 1])
    for subview in @subviews
      $section.append(subview.render().$el)
    @
