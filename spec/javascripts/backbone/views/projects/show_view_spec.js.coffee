describe "ProjectMonitor.Views.Projects.ShowView", ->
  describe "project", ->
    beforeEach ->
      @project = new ProjectMonitor.Models.Project {name: 'Project Monitor', aggregate: false}
      @view = new ProjectMonitor.Views.Projects.ShowView {model: @project}
      @$html = @view.render().$el
      @text = @$html.text()

    it "should include the name", ->
      expect(@text).toContain(@project.get("name"))

    it "should include the history", ->
      expect(@$html).toContain(".history")

  describe "aggregate", ->
    beforeEach ->
      @project = new ProjectMonitor.Models.Project {name: 'Project Monitor', aggregate: true}
      @view = new ProjectMonitor.Views.Projects.ShowView {model: @project}
      @$html = @view.render().$el
      @text = @$html.text()

    it "should include the name", ->
      expect(@text).toContain(@project.get("name"))

    it "should not include the history", ->
      expect(@$html).not.toContain(".history")

