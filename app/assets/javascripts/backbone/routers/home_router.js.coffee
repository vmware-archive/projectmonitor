class ProjectMonitor.Routers.HomeRouter extends Backbone.Router
  initialize: (options) ->
    @tiles = new ProjectMonitor.Collections.Tiles()
    @tiles.reset options.tiles

  routes:
    "home"    : "index"

  index: ->
    @view = new ProjectMonitor.Views.HomeView(collection: @tiles)
    $(".tiles").html(@view.render().el)
