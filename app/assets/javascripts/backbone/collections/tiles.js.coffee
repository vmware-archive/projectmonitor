ProjectMonitor.Collections ||= {}

class ProjectMonitor.Collections.Tiles extends Backbone.Collection
  model: ProjectMonitor.Models.Tile
  url: "/tiles"
