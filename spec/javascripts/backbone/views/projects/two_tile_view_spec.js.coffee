describe "ProjectMonitor.Views.Projects.TwoTileView", ->
    beforeEach ->
      build = new ProjectMonitor.Models.Build {name: 'Project Monitor', aggregate: false, statuses: [true, false, true], last_build: "4d"}
      tracker = new ProjectMonitor.Models.Tracker {velocity: 9, variance: 10, delivered: 9, open: 5, velocities: [12, 15, 20, 40, 10]}
      @project = new ProjectMonitor.Models.Project {build: build, tracker: tracker}
      @view = new ProjectMonitor.Views.Projects.TwoTileView {model: @project}
      @$html = @view.render().$el

    it "should include wide build view", ->
      expect(@$html).toContain(".build.wide")

    it "should include wide tracker view", ->
      expect(@$html).toContain(".tracker.wide")
