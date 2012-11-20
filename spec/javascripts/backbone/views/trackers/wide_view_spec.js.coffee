describe "ProjectMonitor.Views.Trackers.WideView", ->
  beforeEach ->
    @tracker = new ProjectMonitor.Models.Tracker {velocity: 9, variance: 10, delivered: 9, open: 5, velocities: [12, 15, 20, 40, 10]}
    @view = new ProjectMonitor.Views.Trackers.WideView {model: @tracker}
    @$html = @view.render().$el

  it "should include the velocity", ->
    expect(@$html.find(".velocity")).toHaveText(@tracker.get("velocity"))

  it "should include the variance", ->
    expect(@$html.find(".variance")).toHaveText(@tracker.get("variance"))

  it "should include the delivered story count", ->
    expect(@$html.find(".delivered")).toHaveText(@tracker.get("delivered"))

  it "should include the open story count", ->
    expect(@$html.find(".open")).toHaveText(@tracker.get("open"))

  it "should include the velocity chart", ->
    expect(@$html.find(".velocities li:nth-child(1)")).toHaveText("12")
    expect(@$html.find(".velocities li:nth-child(2)")).toHaveText("15")
    expect(@$html.find(".velocities li:nth-child(3)")).toHaveText("20")
    expect(@$html.find(".velocities li:nth-child(4)")).toHaveText("40")
    expect(@$html.find(".velocities li:nth-child(5)")).toHaveText("10")
