describe "ProjectMonitor.Views.NewRelics.SmallView", ->
  beforeEach ->
    @new_relic = new ProjectMonitor.Models.NewRelic {times: [12, 15, 20, 40, 10]}
    @view = new ProjectMonitor.Views.NewRelics.SmallView {model: @new_relic}
    @$html = @view.render().$el

  it "should include the times chart", ->
    expect(@$html.find(".times li:nth-child(1)")).toHaveText("12")
    expect(@$html.find(".times li:nth-child(2)")).toHaveText("15")
    expect(@$html.find(".times li:nth-child(3)")).toHaveText("20")
    expect(@$html.find(".times li:nth-child(4)")).toHaveText("40")
    expect(@$html.find(".times li:nth-child(5)")).toHaveText("10")
