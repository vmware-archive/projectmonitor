describe "ProjectMonitor.Models.Project", ->
  it "should include child models", ->
    project = new ProjectMonitor.Models.Project
      build: { name: 'Project Monitor', aggregate: false, statuses: [true, false, true], last_build: "4d" }
      tracker: { velocity: 9, variance: 10, delivered: 9, open: 5, velocities: [12, 15, 20, 40, 10] }
      new_relic: { times: [10, 20, 50, 80, 100, 90, 80, 90, 40, 40] }
      airbrake: { error_count: 9, last_error: "RuntimeError: Workflow" }

    expect(project.get("build")).toBeDefined()
    expect(project.get("tracker")).toBeDefined()
    expect(project.get("new_relic")).toBeDefined()
    expect(project.get("airbrake")).toBeDefined()

  it "should not include undefined airbrake model", ->
    project = new ProjectMonitor.Models.Project
      build: { name: 'Project Monitor', aggregate: false, statuses: [true, false, true], last_build: "4d" }
      tracker: { velocity: 9, variance: 10, delivered: 9, open: 5, velocities: [12, 15, 20, 40, 10] }
      new_relic: { times: [10, 20, 50, 80, 100, 90, 80, 90, 40, 40] }

    expect(project.get("airbrake")).not.toBeDefined()

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

