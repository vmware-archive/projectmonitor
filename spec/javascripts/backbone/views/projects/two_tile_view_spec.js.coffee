describe "ProjectMonitor.Views.Projects.TwoTileView", ->
    beforeEach ->
      build = new ProjectMonitor.Models.Build(name: 'Project Monitor', aggregate: false, statuses: [true, false, true], last_build: "4d")
      tracker = new ProjectMonitor.Models.Tracker {velocity: 9, variance: 10, delivered: 9, open: 5, velocities: [12, 15, 20, 40, 10]}
      subviews = [
        new ProjectMonitor.Views.BuildView(model: build, size: "wide")
        new ProjectMonitor.Views.TrackerView(model: tracker, size: "wide")
      ]
      view = new ProjectMonitor.Views.Projects.OneTileView(model: {subviews})
      setFixtures(view.render().$el)

    it "should include wide build view", ->
      expect($("section")).toContain("article.build.wide")

    it "should include wide tracker view", ->
      expect($("section")).toContain("article.build.wide")
