describe "ProjectMonitor.Model.Project", ->
  it "should include child models", ->
    project = new ProjectMonitor.Models.Project
      build: { name: 'Project Monitor', aggregate: false, statuses: [true, false, true], last_build: "4d" }
      tracker: { velocity: 9, variance: 10, delivered: 9, open: 5, velocities: [12, 15, 20, 40, 10] }
      new_relic: { times: [10, 20, 50, 80, 100, 90, 80, 90, 40, 40] }
      airbrake: { error_count: 9, last_error: "RuntimeError: Workflow" }

    expect(project.get("build")).toBeDefined()
    expect(project.get("tracker")).toBeDefined()
    expect(project.get("new_relic")).toBeDefined()
    expect(project.get("airbrake")).toBeDefined()

  it "should not include undefined airbrake model", ->
    project = new ProjectMonitor.Models.Project
      build: { name: 'Project Monitor', aggregate: false, statuses: [true, false, true], last_build: "4d" }
      tracker: { velocity: 9, variance: 10, delivered: 9, open: 5, velocities: [12, 15, 20, 40, 10] }
      new_relic: { times: [10, 20, 50, 80, 100, 90, 80, 90, 40, 40] }

    expect(project.get("airbrake")).not.toBeDefined()
