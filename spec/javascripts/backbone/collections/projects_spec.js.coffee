  describe "#refresh", ->
    beforeEach ->
      spyOn(ProjectMonitor.Collections.Projects.prototype, "fetch")
      @project = new ProjectMonitor.Collections.Projects()
      spyOn(window, "setTimeout")
      @project.refresh()

    it "should fetch the collection", ->
      expect(ProjectMonitor.Collections.Projects.prototype.fetch).toHaveBeenCalled()

    it "should execute periodically", ->
      expect(window.setTimeout).toHaveBeenCalled()
