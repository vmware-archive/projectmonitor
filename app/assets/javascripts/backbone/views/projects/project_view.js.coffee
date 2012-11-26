ProjectMonitor.Views.Projects ||= {}

class ProjectMonitor.Views.Projects.ProjectView extends Backbone.View

  render: ->
    view = switch @model.subviews.length
      when 1 then new ProjectMonitor.Views.Projects.OneTileView(model: @model)
      when 2 then new ProjectMonitor.Views.Projects.TwoTileView(model: @model)
      when 3 then new ProjectMonitor.Views.Projects.ThreeTileView(model: @model)
      else new ProjectMonitor.Views.Projects.FourTileView(model: @model)
    $(@el).html(view.render().el)
    @
