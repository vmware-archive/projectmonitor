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
    chartEl = $('#iteration-story-state-counts', @el).get(0)
    marginTop = 10
    marginRight = 5
    marginBottom = 25
    marginLeft = 35
    paddingBottom = 5
    paddingLeft = 5
    width = 490
    height = 143
    rectWidth = 68
    currentVelocity = @model.get('current_velocity')
    chartHeight = height-marginTop-marginBottom
    chartWidth = width-marginLeft-marginRight

    # Setup chart SVG element
    svg = d3.select(chartEl)
      .append('svg')
        .attr('class', 'bar-chart')
        .attr('width', width)
        .attr('height', height)
    # chartEl = $('#iteration-story-state-counts svg', @el).get(0)

    # Set up svg defs to store pattern
    svg.append('defs')
      .append('pattern')
        .attr("id", "whomp-whomp")
        .attr('width', rectWidth)
        .attr('height', '20px')
        .attr('patternUnits', 'userSpaceOnUse')
        # .attr('transform', 'rotate(-15 '+rectWidth/2+' 0)')
    pattern = svg.select('defs pattern')

    # Animated pattern inside svg of the accepted candy striping
    pattern.append("rect")
      .attr('width', rectWidth)
      .attr('height', 20)
      .attr("class", "pattern-stripe-off")
      .attr('x', 0)
      .attr('y', 0)
    pattern.append("rect")
      .attr('width', rectWidth+20)
      .attr('height', 10)
      .attr("class", "pattern-stripe")
      .attr('x', 0)
      .attr('y', 0)
      .attr('transform', 'rotate(10)')
      .append('animate')
        .attr('attributeName', 'y')
        .attr('from', '0')
        .attr('to', '-20')
        .attr('repeatCount', 'indefinite')
        .attr('dur', '2s')
        .attr('calcMode', 'linear')
    pattern.append("rect")
      .attr('width', rectWidth+20)
      .attr('height', 10)
      .attr("class", "pattern-stripe")
      .attr('x', 0)
      .attr('y', 20)
      .attr('transform', 'rotate(10)')
      .append('animate')
        .attr('attributeName', 'y')
        .attr('from', '20')
        .attr('to', '0')
        .attr('repeatCount', 'indefinite')
        .attr('dur', '2s')
        .attr('calcMode', 'linear')

    chart = svg.append('g')
      .attr("class", "iteration-state-counts-chart")

    # Setup discrete ordinal range for x axis
    x_domain= ["unstarted","started","finished","delivered","accepted","rejected"]
    x_scale = d3.scale.ordinal()
      .rangeBands([marginLeft, marginLeft+chartWidth])
      .domain(x_domain)
    x_axis = d3.svg.axis()
      .scale(x_scale)
      .tickSize(0)
      .tickPadding(paddingBottom)
    chart.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0, " + (marginTop+chartHeight) + ")")
      .call(x_axis)

    # Setup y axis
    y_min = d3.min(jData, (d) ->
      d.value)
    y_max = d3.max(jData, (d) ->
      d.value)
    y_max = 8 unless y_max >= 8 #minimum of 8
    y_scale = d3.scale.linear()
      .range([marginTop, marginTop+chartHeight])
      .domain([y_max, y_min])
    y_axis = d3.svg.axis()
      .scale(y_scale)
      .orient("left") 
      .ticks(3)
      .tickSize(-(width-marginLeft-marginRight), 0, 0)
      .tickPadding(paddingLeft)
    chart.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate(" + marginLeft + ", 0)")
      .call(y_axis)

    # Populate chart data elements
    chart.selectAll("rect")
      .data(jData)
      .enter()
      .append("rect")
        .attr("x", (d) ->
          x_scale(d.label)+4)
        .attr("width", rectWidth + "px")
        .attr("data-value", (d) -> 
          d.value)
        .attr("data-scaled-value", (d) -> 
          y_scale(d.value))
        .attr("y", (d) -> 
          y_scale(d.value))
        .attr("height", (d) ->
          marginTop+chartHeight-y_scale(d.value))
        .attr("class", (d) ->
          if d.label == "accepted" && d.value > currentVelocity
            return "whomp-whomp"
          else
            return ""
          )
    @