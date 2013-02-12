class ProjectMonitor.Routers.HomeRouter extends Backbone.Router
  initialize: (options) ->
    @projects = new ProjectMonitor.Collections.Projects()
    @projects.reset options.projects

  routes:
    ""    : "index"

  index: ->
    @view = new ProjectMonitor.Views.HomeView(collection: @projects)
    $(".tiles").html(@view.render().el)
