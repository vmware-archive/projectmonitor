ProjectMonitor.Views.Projects ||= {}

class ProjectMonitor.Views.Projects.OneTileView extends ProjectMonitor.Views.Projects.BaseView
  className: "tile one-tile"
  template: JST["backbone/templates/projects/one_tile"]

  render: ->
    model =
      build_view: (new ProjectMonitor.Views.Builds.LargeView model: @model.get("build")).render().$el.html()
    $(@el).html(@template(model))
    @
