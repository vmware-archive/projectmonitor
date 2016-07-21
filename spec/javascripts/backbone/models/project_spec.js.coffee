describe "ProjectMonitor.Models.Project", ->
  it "should include child models", ->
    project = BackboneFactory.create("complete_project")

    expect(project.get("build")).toBeDefined()
    expect(project.get("tracker")).toBeDefined()

  it "should not include undefined tracker model", ->
    project = BackboneFactory.create("project")

    expect(project.get("tracker")).not.toBeDefined()

  describe "#update", ->
    beforeEach ->
      @build_changed = jasmine.createSpy()

    describe "when the project contains only build information", ->
      beforeEach ->
        @project = BackboneFactory.create("project")
        @project.get("build").on("change", @build_changed)
        attributes = { build: { code: "NEW PROJ"} }
        @project.update(attributes)

      it "should update build model", ->
        expect(@project.get("build").get("code")).toEqual("NEW PROJ")

      it "should fire build change event", ->
        expect(@build_changed).toHaveBeenCalled()

      describe "when tracker information is then added", ->
        beforeEach ->
          attributes = {
            tracker: {
              current_velocity: 5
              last_ten_velocities: [1,2,3,4,5,6]
              open_stories_count: 14
              stories_to_accept_count: 0
              tracker_online: true
              volatility: 111
            }
          }
          @project.update(attributes)

        it "should set the tracker model", ->
          expect(@project.get("tracker")).toEqual(jasmine.any(ProjectMonitor.Models.Tracker))

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
        expect(@build_changed).toHaveBeenCalled()

      it "should fire tracker change event", ->
        expect(@tracker_changed).toHaveBeenCalled()
