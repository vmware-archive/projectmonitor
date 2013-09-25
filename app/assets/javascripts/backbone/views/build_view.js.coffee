ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.BuildView extends Backbone.View
  pollIntervalSeconds: 30
  className: "build"
  tagName: "article"
  template: JST["backbone/templates/build"]

  initialize: (options) ->
    @model.on("change", @render, @)

  render: ->
    @$el.html(@template(@model.toJSON()))
    @$el.removeClass("offline success failure indeterminate")
    @$el.addClass(@model.get('status'))
    if @model.get("building")
      @$el.addClass('building')
    else
      @$el.removeClass('building')
    $lastBuild = @$('.time-since-last-build')
    timeSince = moment(new Date($lastBuild.text())).fromNow()
    $lastBuild.text(timeSince)
    @
