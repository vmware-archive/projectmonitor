describe "ProjectMonitor.Views.Airbrakes.SmallView", ->
  beforeEach ->
    @airbrake = new ProjectMonitor.Models.Airbrake {error_count: 9, last_error: "RuntimeError: Workflow"}
    @view = new ProjectMonitor.Views.Airbrakes.SmallView {model: @airbrake}
    @$html = @view.render().$el

  it "should include the error count", ->
    expect(@$html.find(".error-count")).toHaveText(@airbrake.get("error_count"))

  it "should include the last error", ->
    expect(@$html.find(".last-error")).toHaveText(@airbrake.get("last_error"))
