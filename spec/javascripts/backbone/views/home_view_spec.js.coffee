describe "ProjectMonitor.Views.HomeView", ->
  it "should render project list", ->
    tiles = new ProjectMonitor.Collections.Tiles([BackboneFactory.create('tile')])
    view = new ProjectMonitor.Views.HomeView(collection: tiles)
    expect(view.render().$el).toContain("article.build")
