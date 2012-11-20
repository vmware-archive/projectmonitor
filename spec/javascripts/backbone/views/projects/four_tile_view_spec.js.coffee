describe "ProjectMonitor.Views.Projects.FourTileView", ->
    beforeEach ->
      build = new ProjectMonitor.Models.Build {name: 'Project Monitor', aggregate: false, statuses: [true, false, true], last_build: "4d"}
      tracker = new ProjectMonitor.Models.Tracker {velocity: 9, variance: 10, delivered: 9, open: 5, velocities: [12, 15, 20, 40, 10]}
      new_relic = new ProjectMonitor.Models.NewRelic {times: [12, 15, 20, 40, 10]}
      airbrake = new ProjectMonitor.Models.Airbrake {error_count: 9, last_error: "RuntimeError: Workflow"}
      @project = new ProjectMonitor.Models.Project {build: build, tracker: tracker, new_relic: new_relic, airbrake: airbrake}
      @view = new ProjectMonitor.Views.Projects.FourTileView {model: @project}
      @$html = @view.render().$el

    it "should include small build view", ->
      expect(@$html).toContain(".build.small")

    it "should include small tracker view", ->
      expect(@$html).toContain(".tracker.small")

    it "should include small new relic view", ->
      expect(@$html).toContain(".new-relic.small")

    it "should include small airbrake view", ->
      expect(@$html).toContain(".airbrake.small")
