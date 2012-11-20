ProjectMonitor.Views.Projects ||= {}

class ProjectMonitor.Views.Projects.OneTileView extends Backbone.View
  template: JST["backbone/templates/projects/one_tile"]

  render: ->
    model =
      build_view: (new ProjectMonitor.Views.Builds.LargeView model: @model.get("build")).render().$el.html()
    $(@el).html(@template(model))
    return this
