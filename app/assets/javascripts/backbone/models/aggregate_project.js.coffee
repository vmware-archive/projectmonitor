class ProjectMonitor.Models.AggregateProject extends Backbone.Model
  urlRoot: '/aggregate_projects'
  paramRoot: 'aggregate_project'
  timeout: 30000

  initialize: (attributes, options) ->
    @id = attributes.id
    @refresh()

  refresh: ->
    @fetch()
    setTimeout((=> @refresh()), @timeout)
