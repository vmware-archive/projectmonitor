describe "ProjectMonitor.Views.Projects.OneTileView", ->
    beforeEach ->
      build = new ProjectMonitor.Models.Build(name: 'Project Monitor', aggregate: false, statuses: [true, false, true], last_build: "4d")
      subviews = [new ProjectMonitor.Views.BuildView(model: build, size: "large")]
      view = new ProjectMonitor.Views.Projects.OneTileView(model: {subviews})
      setFixtures(view.render().$el)

    it "should include large build view", ->
      expect($("section")).toContain("article.build.large")
