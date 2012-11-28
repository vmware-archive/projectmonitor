describe "ProjectMonitor.Views.NewRelicView", ->
  beforeEach ->
    @new_relic = new ProjectMonitor.Models.NewRelic {times: [12, 15, 20, 40, 10]}
    @view = new ProjectMonitor.Views.NewRelicView {model: @new_relic, size: "huge"}
    setFixtures(@view.render().$el)

  it "should include an article", ->
    expect($("article")).toExist()

  it "should include new_relic class", ->
    expect($("article")).toHaveClass("new_relic")

  it "should include size class", ->
    expect($("article")).toHaveClass("huge")

  it "should include the times chart", ->
    expect($(".times dd:nth-child(1) span")).toHaveAttr("style", "height: 12%")
    expect($(".times dd:nth-child(2) span")).toHaveAttr("style", "height: 15%")
    expect($(".times dd:nth-child(3) span")).toHaveAttr("style", "height: 20%")
    expect($(".times dd:nth-child(4) span")).toHaveAttr("style", "height: 40%")
    expect($(".times dd:nth-child(5) span")).toHaveAttr("style", "height: 10%")
