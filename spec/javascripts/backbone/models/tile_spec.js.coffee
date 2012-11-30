describe "ProjectMonitor.Views.Tile", ->
  it "should include child models", ->
    tile = new ProjectMonitor.Models.Tile
      build: { name: 'Project Monitor', aggregate: false, statuses: [true, false, true], last_build: "4d" }
      tracker: { velocity: 9, variance: 10, delivered: 9, open: 5, velocities: [12, 15, 20, 40, 10] }
      new_relic: { times: [10, 20, 50, 80, 100, 90, 80, 90, 40, 40] }
      airbrake: { error_count: 9, last_error: "RuntimeError: Workflow" }

    expect(tile.get("build")).toBeDefined()
    expect(tile.get("tracker")).toBeDefined()
    expect(tile.get("new_relic")).toBeDefined()
    expect(tile.get("airbrake")).toBeDefined()

  it "should not include undefined airbrake model", ->
    tile = new ProjectMonitor.Models.Tile
      build: { name: 'Project Monitor', aggregate: false, statuses: [true, false, true], last_build: "4d" }
      tracker: { velocity: 9, variance: 10, delivered: 9, open: 5, velocities: [12, 15, 20, 40, 10] }
      new_relic: { times: [10, 20, 50, 80, 100, 90, 80, 90, 40, 40] }

    expect(tile.get("airbrake")).not.toBeDefined()
