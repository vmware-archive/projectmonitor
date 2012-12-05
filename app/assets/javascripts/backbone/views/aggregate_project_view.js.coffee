ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.AggregateProjectView extends Backbone.View
  tagName: "li"
  className: "aggregate_project"
  template: JST["backbone/templates/aggregate_project"]

  initialize: (options) ->
    @model.on("change", @render, @)

  render: ->
    @$el.html(@template(@model.toJSON()))
    article = @$el.find("article")
    article.removeClass("offline success failure indeterminate")
    article.addClass(@model.get('status'))
    @
