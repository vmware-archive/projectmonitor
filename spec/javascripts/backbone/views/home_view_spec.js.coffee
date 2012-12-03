describe "ProjectMonitor.Views.HomeView", ->
  it "should render tile list", ->
    tiles = new ProjectMonitor.Collections.Tiles([BackboneFactory.create('project')])
    view = new ProjectMonitor.Views.HomeView(collection: tiles)
    expect(view.render().$el).toContain("article.build")
