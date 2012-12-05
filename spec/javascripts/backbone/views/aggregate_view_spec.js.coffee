describe "ProjectMonitor.Views.AggregateProjectView", ->
  describe "common behavior", ->
    beforeEach ->
      @aggregate = BackboneFactory.create("aggregate_project")
      @view = new ProjectMonitor.Views.AggregateProjectView(model: @aggregate)

    describe "status", ->
      describe "when the build succeeded", ->
        beforeEach ->
          @aggregate.set(status: "success")
          setFixtures(@view.render().$el)

        it "should have success class", ->
          expect($(".aggregate")).toHaveClass("success")

      describe "when the build failed", ->
        beforeEach ->
          @aggregate.set(status: "failure")
          setFixtures(@view.render().$el)

        it "should have failed class", ->
          expect($(".aggregate")).toHaveClass("failure")

    describe "view", ->
      beforeEach ->
        setFixtures(@view.render().$el)

      it "should have an article", ->
        expect($("article")).toExist()

      it "should include the code", ->
        expect($(".code")).toHaveText(@aggregate.get("code"))

  describe "when build model changes", ->
    it "should render the view", ->
      aggregate = BackboneFactory.create("aggregate_project")
      spyOn(ProjectMonitor.Views.AggregateProjectView.prototype, "render")
      view = new ProjectMonitor.Views.AggregateProjectView(model: aggregate)
      aggregate.set({code: "NEW CODE"})
      expect(ProjectMonitor.Views.AggregateProjectView.prototype.render).toHaveBeenCalled()

