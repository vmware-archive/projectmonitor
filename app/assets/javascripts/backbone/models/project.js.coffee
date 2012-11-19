class ProjectMonitor.Models.Project extends Backbone.Model
  paramRoot: 'project'

  defaults:
    name: null

class ProjectMonitor.Collections.ProjectsCollection extends Backbone.Collection
  model: ProjectMonitor.Models.Project
  url: '/projects'
