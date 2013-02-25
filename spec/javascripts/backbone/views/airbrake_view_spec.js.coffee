describe "ProjectMonitor.Views.AirbrakeView", ->
  beforeEach ->
    @airbrake = new ProjectMonitor.Models.Airbrake (error_count: 9, last_error: "RuntimeError: Workflow")
    @view = new ProjectMonitor.Views.AirbrakeView (model: @airbrake, size:"superbig")
    setFixtures(@view.render().$el)

  it "should include the error count", ->
    expect($(".error-count")).toHaveText('9')

  it "should include the last error", ->
    expect($(".last-error")).toHaveText(@airbrake.get("last_error"))

  it "should have class airbrake", ->
    expect($("article")).toHaveClass('airbrake')

  it "should be an article element", ->
    expect(@view.tagName).toEqual("article")
