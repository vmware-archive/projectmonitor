describe "ProjectMonitor.Views.TrackerView", ->
  describe "#render", ->
    beforeEach ->
      @tracker = BackboneFactory.create("complete_project").get("tracker")
      @view = new ProjectMonitor.Views.TrackerView {model: @tracker}
      setFixtures(@view.render().$el)

    it "should have tracker class", ->
      expect($("article")).toHaveClass("tracker")

    it "should include the velocity", ->
      expect($(".current-velocity")).toHaveText(@tracker.get("current_velocity"))

    it "should include the variance", ->
      expect($(".current-variance").text()).toContain(@tracker.get("variance"))

    it "should include the story states chart", ->
      expect($(".bar-chart g.iteration-state-counts-chart")).toExist()

      expect($(".bar-chart g.iteration-state-counts-chart g.x.axis")).toExist()
      expect($(".bar-chart g.iteration-state-counts-chart g.y.axis")).toExist()

      expect($(".bar-chart g.iteration-state-counts-chart rect").eq(0).attr('x')).toContain("39")
      expect($(".bar-chart g.iteration-state-counts-chart rect").eq(0).attr('y')).toContain("109")

      expect($(".bar-chart g.iteration-state-counts-chart rect").eq(1).attr('x')).toContain("114")
      expect($(".bar-chart g.iteration-state-counts-chart rect").eq(1).attr('y')).toContain("73")

      expect($(".bar-chart g.iteration-state-counts-chart rect").eq(2).attr('x')).toContain("189")
      expect($(".bar-chart g.iteration-state-counts-chart rect").eq(2).attr('y')).toContain("118")

      expect($(".bar-chart g.iteration-state-counts-chart rect").eq(3).attr('x')).toContain("264")
      expect($(".bar-chart g.iteration-state-counts-chart rect").eq(3).attr('y')).toContain("73")

      expect($(".bar-chart g.iteration-state-counts-chart rect").eq(4).attr('x')).toContain("339")
      expect($(".bar-chart g.iteration-state-counts-chart rect").eq(4).attr('y')).toContain("10")

      expect($(".bar-chart g.iteration-state-counts-chart rect").eq(5).attr('x')).toContain("414")
      expect($(".bar-chart g.iteration-state-counts-chart rect").eq(5).attr('y')).toContain("109")

    describe "when the tracker model is offline", ->
      beforeEach ->
        @tracker.set('tracker_online', false)
        setFixtures(@view.render().$el)

      it "displays 'No Connection'", ->
        expect($('.no-connection')).toExist()

    describe "when the tracker project is online but has no velocity", ->
      beforeEach ->
        @tracker.set('last_ten_velocities', [])
        setFixtures(@view.render().$el)

      it "does not show the history graph", ->
        expect($('.velocities span')).not.toExist()


  describe "when tracker model changes", ->
    it "should render the view", ->
      tracker = BackboneFactory.create("complete_project").get("tracker")
      spyOn(ProjectMonitor.Views.TrackerView.prototype, "render")
      view = new ProjectMonitor.Views.TrackerView(model: tracker)
      tracker.set({velocity: 78})
      expect(ProjectMonitor.Views.TrackerView.prototype.render).toHaveBeenCalled()
