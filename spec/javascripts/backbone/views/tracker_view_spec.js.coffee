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
      expect($(".variance").text()).toContain(@tracker.get("variance"))

    it "should include the delivered story count", ->
      expect($(".stories-to-accept-count")).toHaveText(@tracker.get("stories_to_accept_count"))

    it "should include the open story count", ->
      expect($(".open-stories-count")).toHaveText(@tracker.get("open_stories_count"))

    it "should include the velocity chart", ->
      expect($(".velocities dd:nth-child(1) span").attr('style')).toContain("1%")
      expect($(".velocities dd:nth-child(2) span").attr('style')).toContain("2%")
      expect($(".velocities dd:nth-child(3) span").attr('style')).toContain("3%")
      expect($(".velocities dd:nth-child(4) span").attr('style')).toContain("4%")
      expect($(".velocities dd:nth-child(5) span").attr('style')).toContain("50%")
      expect($(".velocities dd:nth-child(6) span").attr('style')).toContain("60%")
      expect($(".velocities dd:nth-child(7) span").attr('style')).toContain("70%")
      expect($(".velocities dd:nth-child(8) span").attr('style')).toContain("80%")
      expect($(".velocities dd:nth-child(9) span").attr('style')).toContain("90%")
      expect($(".velocities dd:nth-child(10) span").attr('style')).toContain("100%")

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
