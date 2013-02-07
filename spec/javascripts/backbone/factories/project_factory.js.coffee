BackboneFactory.define 'project', ProjectMonitor.Models.Project, ->
  {
    project_id: 90890
    build:
      code: 'PROJ'
      aggregate: false
      status: "success"
      statuses: [true, false, true, true, false, true, true, false, true, true, false, false]
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
      current_velocity: 4
      variance: 10
      stories_to_accept_count: 5
      open_stories_count: 9
      last_ten_velocities: [ 1, 2, 3, 4, 50, 60, 70, 80, 90, 100]
  }
