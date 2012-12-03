BackboneFactory.define 'project', ProjectMonitor.Models.Project, ->
  {
    project_id: 90890
    build:
      code: 'PROJ'
      aggregate: false
      status: "success"
      statuses: [true, false, true, true, false, true, true, false, true, true]
      time_since_last_build: "4d"
  }

BackboneFactory.define 'complete_project', ProjectMonitor.Models.Project, ->
  {
    project_id: 90890
    build:
      code: 'PROJ'
      aggregate: false
      status: "success"
      statuses: [true, false, true, true, false, true, true, false, true, true]
      time_since_last_build: "4d"
    tracker:
      velocity: 4
      variance: 10
      delivered: 5
      open: 9
      velocities: [ 1, 2, 3, 4, 50, 60]
  }
