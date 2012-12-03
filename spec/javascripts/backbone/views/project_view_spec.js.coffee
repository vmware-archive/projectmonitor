describe "ProjectMonitor.Views.ProjectView", ->
  describe "one tile view", ->
    beforeEach ->
      @model = BackboneFactory.create('project')

      view = new ProjectMonitor.Views.ProjectView(model: @model)
      setFixtures(view.render().$el)

    it "should include build view", ->
      expect($("section")).toContain("article.build")

  describe "four tile view", ->
    beforeEach ->
      @model = BackboneFactory.create('complete_project')

      view = new ProjectMonitor.Views.ProjectView(model: @model)
      setFixtures(view.render().$el)

    it "should include the project id", ->
      expect($("section").parent().data("project_id")).toEqual(@model.get("project_id"))

    it "should include build view", ->
      expect($("section")).toContain("article.build")

    it "should include tracker view", ->
      expect($("section")).toContain("article.tracker")
