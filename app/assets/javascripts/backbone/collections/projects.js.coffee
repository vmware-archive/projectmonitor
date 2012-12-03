ProjectMonitor.Collections ||= {}

class ProjectMonitor.Collections.Projects extends Backbone.Collection
  model: ProjectMonitor.Models.Project
  url: "/projects"
