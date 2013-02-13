describe "ProjectMonitor.Routers.HomeRouter", ->
  beforeEach ->
    spyOn(ProjectMonitor.Routers.HomeRouter.prototype, "index")
    @router = new ProjectMonitor.Routers.HomeRouter({tiles: [BackboneFactory.create("project")]});
    try
      Backbone.history.start()
    catch e

  afterEach ->
    Backbone.history.stop()

  it "should call index callback", ->
    @router.navigate("", true)
    expect(ProjectMonitor.Routers.HomeRouter.prototype.index).toHaveBeenCalled()
