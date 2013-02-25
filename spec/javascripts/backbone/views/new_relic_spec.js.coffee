describe "ProjectMonitor.Views.NewRelicView", ->
  beforeEach ->
    @new_relic = new ProjectMonitor.Models.NewRelic {times: [12, 15, 20, 40, 10]}
    @view = new ProjectMonitor.Views.NewRelicView {model: @new_relic}
    setFixtures(@view.render().$el)

  it "should include the times chart", ->
    expect($(".times dd:nth-child(1) span").attr("style")).toContain("12%")
    expect($(".times dd:nth-child(2) span").attr("style")).toContain("15%")
    expect($(".times dd:nth-child(3) span").attr("style")).toContain("20%")
    expect($(".times dd:nth-child(4) span").attr("style")).toContain("40%")
    expect($(".times dd:nth-child(5) span").attr("style")).toContain("10%")

  it "should have class new_relic", ->
    expect($("article")).toHaveClass('new_relic')

  it "should be an article element", ->
    expect(@view.tagName).toEqual("article")
