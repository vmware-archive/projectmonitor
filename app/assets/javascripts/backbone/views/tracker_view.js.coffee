ProjectMonitor.Views ||= {}

class ProjectMonitor.Views.TrackerView extends Backbone.View
  className: "tracker"
  tagName: "article"
  template: JST["backbone/templates/tracker"]
  chart: null

  initialize: (options) ->
    @model.on("change", @render, @)

  render: ->
    @$el.html(@template($.extend(@model.toJSON(), {size: @size, normalized_velocities: @model.normalized_velocities()})))
    @renderIterationStoryStateCountsChart()
    @

  renderIterationStoryStateCountsChart: ->
    data = JSON.stringify(@model.get 'iteration_story_state_counts')
    jData = eval(data)

    # Setup chart SVG size
    chartEl = $('#iteration-story-state-counts .bar-chart-container', @el).get(0)
    margin_top = 10
    margin_right = 5
    margin_bottom = 25
    margin_left = 35
    padding_bottom = 5
    padding_left = 5
    width = 355
    height = 118
    currentVelocity = @model.get('current_velocity')
    chart_height = height-margin_top-margin_bottom
    d3.select(chartEl)
      .append('svg')
        .attr('class', 'bar-chart')
        .attr('width', width)
        .attr('height', height)
    chartEl = $('#iteration-story-state-counts .bar-chart-container svg', @el).get(0)

    # Setup discrete ordinal range for x axis
    x_domain= ["unstarted","started","finished","delivered","accepted","rejected"]
    x_scale = d3.scale.ordinal()
      .rangeBands([margin_left, width-margin_right])
      .domain(x_domain)
    x_axis = d3.svg.axis()
      .scale(x_scale)
      .tickSize(0)
      .tickPadding(padding_bottom)
    d3.select(chartEl)
      .append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0, " + (margin_top+chart_height+padding_bottom) + ")")
        .call(x_axis)

    # Setup y axis
    y_min = d3.min(jData, (d) ->
      d.value)
    y_max = d3.max(jData, (d) ->
      d.value)
    y_max = 8 unless y_max >= 8 #minimum of 8
    y_scale = d3.scale.linear()
      .range([margin_top, margin_top+chart_height])
      .domain([y_max, y_min])
    y_axis = d3.svg.axis()
      .scale(y_scale)
      .orient("left")
      .ticks(4)
      .tickSize(-(width-margin_left-margin_right), 0, 0)
      .tickPadding(padding_left)
    d3.select(chartEl)
      .append("g")
        .attr("class", "y axis")
        .attr("transform", "translate(" + margin_left + ", " + padding_bottom + ")")
        .call(y_axis)
    d3.select(chartEl)
      .append("text")
        .attr("x", margin_left)
        .attr("y", margin_top+4)
        .attr("transform", "rotate (-90) translate(-110)")
        .text("Points")

    d3.select(chartEl)
      .selectAll("rect")
      .data(jData)
      .enter()
      .append("rect")
        .attr("x", (d) ->
          x_scale(d.label)+6)
        .attr("width", "40px")
        .attr("y", (d) -> 
          margin_top+y_scale(d.value) - 5)
        .attr("height", (d) ->
          margin_top+chart_height-y_scale(d.value))
        .attr("class", (d) ->
          if d.label == "accepted" && d.value > currentVelocity
            return "whomp-whomp"
          else
            return ""
          )
    @