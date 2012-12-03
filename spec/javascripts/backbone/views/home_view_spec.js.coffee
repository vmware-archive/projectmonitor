describe "ProjectMonitor.Views.HomeView", ->
  it "should render tile list", ->
    projects = new ProjectMonitor.Collections.Projects([BackboneFactory.create('project')])
    view = new ProjectMonitor.Views.HomeView(collection: projects)
    expect(view.render().$el).toContain("article.build")
