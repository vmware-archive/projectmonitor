describe "ProjectMonitor.Views.BuildView", ->
  describe "common behavior", ->
    beforeEach ->
      @build = new ProjectMonitor.Models.Build {name: 'PROJ', aggregate: false, statuses: [true, false, true, true, false, true, true, false, true, true], last_build: "4d"}
      @view = new ProjectMonitor.Views.BuildView(model: @build, size: "huge")

    describe "status", ->
      describe "when the build succeeded", ->
        beforeEach ->
          @build.set(status: "success")
          setFixtures(@view.render().$el)

        it "should have success class", ->
          expect($(".build")).toHaveClass("success")

      describe "when the build failed", ->
        beforeEach ->
          @build.set(status: "failure")
          setFixtures(@view.render().$el)

        it "should have failed class", ->
          expect($(".build")).toHaveClass("failure")

    describe "build", ->
      beforeEach ->
        setFixtures(@view.render().$el)

      it "should have an article", ->
        expect($("article")).toExist()

      it "should include the size class", ->
        expect($("article")).toHaveClass('huge')

      it "should include the build class", ->
        expect($("article")).toHaveClass('build')

      it "should include the name", ->
        expect($(".name")).toHaveText(@build.get("name"))

      it "should include the history", ->
        expect($(".statuses li:nth-child(1)")).toHaveClass("success")
        expect($(".statuses li:nth-child(2)")).toHaveClass("failure")
        expect($(".statuses li:nth-child(3)")).toHaveClass("success")

      it "should include the last build time", ->
        expect($(".last-build")).toHaveText("4d")

    describe "aggregate", ->
      beforeEach ->
        @build.set(aggregate: true)
        setFixtures(@view.render().$el)

      it "should include the name", ->
        expect($(".name")).toHaveText(@build.get("name"))

      it "should not include the history", ->
        expect($(".history")).not.toExist()

  describe "when tall", ->
    it "renders last build text", ->
      build = new ProjectMonitor.Models.Build {name: 'PROJ', status: 'success', aggregate: false, statuses: [true, false, true, true, false, true, true, false, true, true], last_build: "4d"}
      view = new ProjectMonitor.Views.BuildView(model: build, size: "tall")
      setFixtures(view.render().$el)
      expect($(".history").text()).toContain("Last build:")

  describe "when wide", ->
    it "renders last build text", ->
      build = new ProjectMonitor.Models.Build {name: 'PROJ', status: 'success', aggregate: false, statuses: [true, false, true, true, false, true, true, false, true, true], last_build: "4d"}
      view = new ProjectMonitor.Views.BuildView(model: build, size: "wide")
      setFixtures(view.render().$el)
      expect($(".history").text()).toContain("Last build:")

  describe "when large", ->
    it "does not render the last build text", ->
      build = new ProjectMonitor.Models.Build {name: 'PROJ', status: 'success', aggregate: false, statuses: [true, false, true, true, false, true, true, false, true, true], last_build: "4d"}
      view = new ProjectMonitor.Views.BuildView(model: build, size: "large")
      setFixtures(view.render().$el)
      expect($(".history").text()).not.toContain("Last build:")

  describe "when small", ->
    it "does not render the last build text", ->
      build = new ProjectMonitor.Models.Build {name: 'PROJ', status: 'success', aggregate: false, statuses: [true, false, true, true, false, true, true, false, true, true], last_build: "4d"}
      view = new ProjectMonitor.Views.BuildView(model: build, size: "small")
      setFixtures(view.render().$el)
      expect($(".history").text()).not.toContain("Last build:")
