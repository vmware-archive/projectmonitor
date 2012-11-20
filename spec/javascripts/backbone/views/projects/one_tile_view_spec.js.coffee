describe "ProjectMonitor.Views.Projects.OneTileView", ->
    beforeEach ->
      build = new ProjectMonitor.Models.Build {name: 'Project Monitor', aggregate: false, statuses: [true, false, true], last_build: "4d"}
      @project = new ProjectMonitor.Models.Project {build: build}
      @view = new ProjectMonitor.Views.Projects.OneTileView {model: @project}
      @$html = @view.render().$el

    it "should include large build view", ->
      expect(@$html).toContain(".build.large")
