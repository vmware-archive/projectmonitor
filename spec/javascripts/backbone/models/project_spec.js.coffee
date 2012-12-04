describe "ProjectMonitor.Models.Project", ->
  it "should include child models", ->
    project = BackboneFactory.create("complete_project")

    expect(project.get("build")).toBeDefined()
    expect(project.get("tracker")).toBeDefined()

  it "should not include undefined airbrake model", ->
    project = BackboneFactory.create("project")

    expect(project.get("tracker")).not.toBeDefined()

  describe "#update", ->
    beforeEach ->
      @build_changed = jasmine.createSpy();

    describe "when the project contains only build information", ->
      beforeEach ->
        @project = BackboneFactory.create("project")
        @project.get("build").on("change", @build_changed)
        attributes = { build: { code: "NEW PROJ"} }
        @project.update(attributes)

      it "should update build model", ->
        expect(@project.get("build").get("code")).toEqual("NEW PROJ")

      it "should fire build change event", ->
        expect(@build_changed).toHaveBeenCalled();

    describe "when the project contains build and tracker information", ->
      beforeEach ->
        @project = BackboneFactory.create("complete_project")
        @tracker_changed = jasmine.createSpy()
        @project.get("build").on("change", @build_changed)
        @project.get("tracker").on("change", @tracker_changed)
        attributes = { build: { code: "NEW PROJ"}, tracker: { velocity: 99} }
        @project.update(attributes)

      it "should update build model", ->
        expect(@project.get("build").get("code")).toEqual("NEW PROJ")

      it "should update tracker model", ->
        expect(@project.get("tracker").get("velocity")).toEqual(99)

      it "should fire build change event", ->
        expect(@build_changed).toHaveBeenCalled();

      it "should fire tracker change event", ->
        expect(@tracker_changed).toHaveBeenCalled();

  describe "#refresh", ->
    beforeEach ->
      spyOn(ProjectMonitor.Models.Project.prototype, "fetch")
      @project = new ProjectMonitor.Models.Project({code: "PROJ"})
      spyOn(window, "setTimeout")
      @project.refresh()

    it "should fetch the model", ->
      expect(ProjectMonitor.Models.Project.prototype.fetch).toHaveBeenCalled()

    it "should execute periodically", ->
      expect(window.setTimeout).toHaveBeenCalled()
