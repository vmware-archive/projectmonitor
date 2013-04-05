BackboneFactory.define 'project', ProjectMonitor.Models.Project, ->
  {
    project_id: do -> Math.floor(Math.random()*99999)
    build:
      code: 'PROJ'
      aggregate: false
      status: "success"
      statuses: [{success: true, url: "http://status.com"}, {success: false, url: "http://status.com"}, {success: true, url: "http://status.com"}, {success: true, url: "http://status.com"}, {success: false, url: "http://status.com"}, {success: true, url: "http://status.com"}, {success: true, url: "http://status.com"}, {success: false, url: "http://status.com"}, {success: true, url: "http://status.com"}, {success: true, url: "http://status.com"}, {success: false, url: "http://status.com"}, {success: false, url: "http://status.com"}]
      published_at: "4d"
  }

BackboneFactory.define 'complete_project', ProjectMonitor.Models.Project, ->
  {
    project_id: 90890
    build:
      code: 'PROJ'
      current_build_url: 'http://placekitten.com/500'
      aggregate: false
      status: "success"
      statuses: [{success: true, url: "http://status.com"}, {success: false, url: "http://status.com"}, {success: true, url: "http://status.com"}, {success: true, url: "http://status.com"}, {success: false, url: "http://status.com"}, {success: true, url: "http://status.com"}, {success: true, url: "http://status.com"}, {success: false, url: "http://status.com"}, {success: true, url: "http://status.com"}, {success: true, url: "http://status.com"}, {success: false, url: "http://status.com"}, {success: false, url: "http://status.com"}]
      published_at: "4d"
    tracker:
      current_velocity: 4
      variance: 10
      stories_to_accept_count: 5
      open_stories_count: 9
      last_ten_velocities: [ 1, 2, 3, 4, 50, 60, 70, 80, 90, 100]
      iteration_story_state_counts: JSON.parse('[{"label":"unstarted","value":4},{"label":"started","value":8},{"label":"finished","value":3},{"label":"delivered","value":8},{"label":"accepted","value":15},{"label":"rejected","value":4}]')
      tracker_online: true
  }
