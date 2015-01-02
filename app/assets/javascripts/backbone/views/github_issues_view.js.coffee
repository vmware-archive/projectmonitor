ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.AirbrakeView extends Backbone.View
  className: "github-issues"
  tagName: "article"
  template: JST["backbone/templates/github_issues"]

  render: ->
    @$el.html(@template(@model.toJSON()))
    @
