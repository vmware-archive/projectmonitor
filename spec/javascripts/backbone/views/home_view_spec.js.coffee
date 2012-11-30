describe "ProjectMonitor.Views.HomeView", ->
  it "should render project list", ->
    projects = new ProjectMonitor.Collections.Projects([BackboneFactory.create('project')])
    view = new ProjectMonitor.Views.HomeView(collection: projects)
    expect(view.render().$el).toContain("article.build")
