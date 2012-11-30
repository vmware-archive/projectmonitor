BackboneFactory.define 'tile', ProjectMonitor.Models.Tile, ->
  {
    build:
      name: 'PROJ'
      aggregate: false
      status: "success"
      statuses: [true, false, true, true, false, true, true, false, true, true]
      last_build: "4d"
  }
