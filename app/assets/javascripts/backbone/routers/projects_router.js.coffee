class ProjectMonitor.Routers.ProjectsRouter extends Backbone.Router
  initialize: (options) ->
    @projects = new ProjectMonitor.Collections.ProjectsCollection()
    @projects.reset options.projects

  routes:
    "new"      : "newProject"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newProject: ->
    @view = new ProjectMonitor.Views.Projects.NewView(collection: @projects)
    $("#projects").html(@view.render().el)

  index: ->
    @view = new ProjectMonitor.Views.Projects.IndexView(projects: @projects)
    $("#projects").html(@view.render().el)

  show: (id) ->
    project = @projects.get(id)

    @view = new ProjectMonitor.Views.Projects.ShowView(model: project)
    $("#projects").html(@view.render().el)

  edit: (id) ->
    project = @projects.get(id)

    @view = new ProjectMonitor.Views.Projects.EditView(model: project)
    $("#projects").html(@view.render().el)
