describe "ProjectMonitor.Views.TileView", ->
  describe "one tile view", ->
    beforeEach ->
      @model = BackboneFactory.create('project')

      view = new ProjectMonitor.Views.TileView(model: @model)
      setFixtures(view.render().$el)

    it "should include build view", ->
      expect($("section")).toContain("article.build")

  describe "four tile view", ->
    beforeEach ->
      @model = BackboneFactory.create('project')

      view = new ProjectMonitor.Views.TileView(model: @model)
      setFixtures(view.render().$el)

    it "should include the project id", ->
      expect($("section").parent().data("project_id")).toEqual(987)

    it "should include build view", ->
      expect($("section")).toContain("article.build")

    it "should include tracker view", ->
      expect($("section")).toContain("article.tracker")

    it "should include new_relic view", ->
      expect($("section")).toContain("article.new_relic")

    it "should include airbrake view", ->
      expect($("section")).toContain("article.airbrake")

