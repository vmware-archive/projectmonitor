describe "ProjectMonitor.Views.Projects.TwoTileView", ->
    beforeEach ->
      build = new ProjectMonitor.Models.Build(name: 'Project Monitor', aggregate: false, statuses: [true, false, true], last_build: "4d")
      tracker = new ProjectMonitor.Models.Tracker {velocity: 9, variance: 10, delivered: 9, open: 5, velocities: [12, 15, 20, 40, 10]}
      subviews = [
        new ProjectMonitor.Views.BuildView(model: build)
        new ProjectMonitor.Views.TrackerView(model: tracker)
      ]
      view = new ProjectMonitor.Views.Projects.TwoTileView(subviews: subviews)
      setFixtures(view.render().$el)

    it "should include build view", ->
      expect($("section")).toContain("article.build")

    it "should include tracker view", ->
      expect($("section")).toContain("article.build")
