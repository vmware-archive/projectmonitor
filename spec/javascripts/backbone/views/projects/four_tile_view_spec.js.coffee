describe "ProjectMonitor.Views.Projects.FourTileView", ->
    beforeEach ->
      build = new ProjectMonitor.Models.Build(name: 'Project Monitor', aggregate: false, statuses: [true, false, true], last_build: "4d")
      new_relic = new ProjectMonitor.Models.NewRelic {times: [12, 15, 20, 40, 10]}
      tracker = new ProjectMonitor.Models.Tracker {velocity: 9, variance: 10, delivered: 9, open: 5, velocities: [12, 15, 20, 40, 10]}
      airbrake = new ProjectMonitor.Models.Airbrake {error_count: 9, last_error: "RuntimeError: Workflow"}
      subviews = [
        new ProjectMonitor.Views.BuildView(model: build, size: "small")
        new ProjectMonitor.Views.TrackerView(model: tracker, size: "small")
        new ProjectMonitor.Views.NewRelicView(model: new_relic, size: "small")
        new ProjectMonitor.Views.AirbrakeView(model: airbrake, size: "small")
      ]
      view = new ProjectMonitor.Views.Projects.OneTileView(model: {subviews})
      setFixtures(view.render().$el)

    it "should include small build view", ->
      expect($("section")).toContain("article.build.small")

    it "should include small tracker view", ->
      expect($("section")).toContain("article.tracker.small")

    it "should include small new_relic view", ->
      expect($("section")).toContain("article.new_relic.small")

    it "should include small airbrake view", ->
      expect($("section")).toContain("article.airbrake.small")

