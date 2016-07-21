ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.ProjectView extends Backbone.View
  tagName: "li"
  className: "project"

  initialize: (options) ->
    @subviews = []
    @subviews.push(new ProjectMonitor.Views.BuildView(model: @model.get("build"))) if @model.get("build")
    @subviews.push(new ProjectMonitor.Views.TrackerView(model: @model.get("tracker"))) if @model.get("tracker")
    @.registerSubView(subview) for subview in @subviews
    @$el.data(project_id: @model.get("project_id"))

  render: ->
    $section = $("<section/>").
      addClass(['one-tile', 'two-tile', 'three-tile', 'four-tile'][@subviews.length - 1])
    for subview in @subviews
      $section.append(subview.render().$el)
    @$el.html($section)
    @
