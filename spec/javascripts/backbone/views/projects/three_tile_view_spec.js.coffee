describe "ProjectMonitor.Views.Projects.ThreeTileView", ->
    beforeEach ->
      build = new ProjectMonitor.Models.Build {name: 'Project Monitor', aggregate: false, statuses: [true, false, true], last_build: "4d"}
      tracker = new ProjectMonitor.Models.Tracker {velocity: 9, variance: 10, delivered: 9, open: 5, velocities: [12, 15, 20, 40, 10]}
      new_relic = new ProjectMonitor.Models.NewRelic {times: [12, 15, 20, 40, 10]}
      @project = new ProjectMonitor.Models.Project {build: build, tracker: tracker, new_relic: new_relic}
      @view = new ProjectMonitor.Views.Projects.ThreeTileView {model: @project}
      @$html = @view.render().$el

    it "should include tall build view", ->
      expect(@$html).toContain(".build.tall")

    it "should include small tracker view", ->
      expect(@$html).toContain(".tracker.small")

    it "should include small new relic view", ->
      expect(@$html).toContain(".new-relic.small")
