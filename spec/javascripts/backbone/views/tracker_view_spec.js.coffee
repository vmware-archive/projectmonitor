describe "ProjectMonitor.Views.TrackerView", ->
  beforeEach ->
    @tracker = new ProjectMonitor.Models.Tracker
      velocity: 9
      variance: 10
      delivered: 9
      open: 5
      velocities: [12, 15, 20, 40, 10]

    @view = new ProjectMonitor.Views.TrackerView {model: @tracker, size: "huge"}
    setFixtures(@view.render().$el)

  it "should have an article", ->
    expect($("article")).toExist()

  it "should have tracker class", ->
    expect($("article")).toHaveClass("tracker")

  it "should have size class", ->
    expect($("article")).toHaveClass("huge")

  it "should include the velocity", ->
    expect($(".velocity")).toHaveText(@tracker.get("velocity"))

  it "should include the variance", ->
    expect($(".variance").text()).toContain(@tracker.get("variance"))

  it "should include the delivered story count", ->
    expect($(".delivered")).toHaveText(@tracker.get("delivered"))

  it "should include the open story count", ->
    expect($(".open")).toHaveText(@tracker.get("open"))

  it "should include the velocity chart", ->
    expect($(".velocities dd:nth-child(1) span").attr('style')).toContain("12%")
    expect($(".velocities dd:nth-child(2) span").attr('style')).toContain("15%")
    expect($(".velocities dd:nth-child(3) span").attr('style')).toContain("20%")
    expect($(".velocities dd:nth-child(4) span").attr('style')).toContain("40%")
    expect($(".velocities dd:nth-child(5) span").attr('style')).toContain("10%")
