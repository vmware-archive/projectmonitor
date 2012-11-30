describe "ProjectMonitor.Views.TileView", ->
  describe "one tile view", ->
    beforeEach ->
      model = new Backbone.Model()
      model.set build: new ProjectMonitor.Models.Build(name: 'Project Monitor', aggregate: false, statuses: [true, false, true], last_build: "4d")

      view = new ProjectMonitor.Views.TileView(model: model)
      setFixtures(view.render().$el)

    it "should include build view", ->
      expect($("section")).toContain("article.build")

  describe "four tile view", ->
    beforeEach ->
      model = new Backbone.Model()
      model.set build: new ProjectMonitor.Models.Build(name: 'Project Monitor', aggregate: false, statuses: [true, false, true], last_build: "4d")
      model.set tracker: new ProjectMonitor.Models.Tracker(velocity: 9, variance: 10, delivered: 9, open: 5, velocities: [12, 15, 20, 40, 10])
      model.set new_relic: new ProjectMonitor.Models.NewRelic(times: [10, 20, 50, 80, 100, 90, 80, 90, 40, 40])
      model.set airbrake: new ProjectMonitor.Models.Airbrake(error_count: 9, last_error: "RuntimeError: Workflow")

      view = new ProjectMonitor.Views.TileView(model: model)
      setFixtures(view.render().$el)

    it "should include build view", ->
      expect($("section")).toContain("article.build")

    it "should include tracker view", ->
      expect($("section")).toContain("article.tracker")

    it "should include new_relic view", ->
      expect($("section")).toContain("article.new_relic")

    it "should include airbrake view", ->
      expect($("section")).toContain("article.airbrake")

