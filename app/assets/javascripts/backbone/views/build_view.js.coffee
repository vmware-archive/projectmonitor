ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.BuildView extends Backbone.View
  pollIntervalSeconds: 30
  fadeIntervalSeconds: 3
  className: "build"
  tagName: "article"
  template: JST["backbone/templates/build"]

  initialize: (options) ->
    @model.on("change", @render, @)

  render: ->
    @$el.html(@template(@model.toJSON()))
    @$el.removeClass("offline success failure indeterminate")
    @$el.addClass(@model.get('status'))
    @_showAsBuilding() if @model.get("building")
    @

  _showAsBuilding: ->
    (f = (i) =>
      @$el.fadeTo(1000, 0.5).fadeTo(1000, 1)
      setTimeout (->
        f i + 1
      ), @fadeIntervalSeconds * 1000
    ) 0
