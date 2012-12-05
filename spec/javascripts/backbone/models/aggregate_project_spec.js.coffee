describe "ProjectMonitor.Models.AggregateProject", ->
  describe "#refresh", ->
    beforeEach ->
      spyOn(ProjectMonitor.Models.AggregateProject.prototype, "fetch")
      @project = new ProjectMonitor.Models.AggregateProject({code: "PROJ"})
      spyOn(window, "setTimeout")
      @project.refresh()

    it "should fetch the model", ->
      expect(ProjectMonitor.Models.AggregateProject.prototype.fetch).toHaveBeenCalled()

    it "should execute periodically", ->
      expect(window.setTimeout).toHaveBeenCalled()
