// GMap mocks
GMap = Class.create();
GMap.prototype = {
	initialize: function(containerElement, mapTypes) {
		this.containerElement = $(containerElement);
		this.mapTypes = mapTypes || [G_MAP_TYPE];
		this.mockInitializedGoogleMap = true;
		this.registeredEventListeners = {};
		this.draggingDisabled = false;
		this.currentMapType = this.mapTypes[0];
		this.controls = [];
	},
	
	setMapType: function(new_type) {
		this.currentMapType = new_type;
	},
	
	getZoomLevel: function() {
		return this.zoom;
	},
	
	getCurrentMapType: function() {
		return this.currentMapType;
	},
	
	disableDragging: function() {
		this.draggingDisabled = true;
	},
	
	disableInfoWindow: function() {
	},
	
	centerAndZoom: function(latlng, zoom) {
		this.centerLatLng = latlng;
		this.zoom = zoom;
	},
	
	addControl: function(control) {
		this.controls.push(control);
	},
	
	getCenterLatLng: function() {
		return this.centerLatLng;
	},
	
	recenterOrPanToLatLng: function(desiredLatLng) {
		this.centerLatLng = desiredLatLng;
	},
	
	simulateOnMoveEvent: function(desiredLatLng) {
		if (this.draggingDisabled) {
			throw "Dragging is disabled";
		};
		this.recenterOrPanToLatLng(desiredLatLng);
		if (this.registeredEventListeners['moveend'] != null) {
			this.registeredEventListeners['moveend']();
		}
	},
	
	addOverlay: function() {
	}
};

// GMap mocks
GMap2 = Class.create();
GMap2.prototype = {
	initialize: function(containerElement) {
		this.initialized = true;
	},
	
	setCenter: function(latlng, zoom) {
		this.center = latlng;
    if (zoom != null) {
      this.zoom = zoom;
    }
  },
	
	setZoom: function(zoom) {
		this.zoom = zoom;
	},
	
	addOverlay: function() {
	},
	
	addControl: function(control) {
	  this.control = control;
	},
	
	getBoundsZoomLevel: function() {
		return 0;
	}
};

GLatLng = Class.create();
GLatLng.prototype = {
	initialize: function(lat, long) {
		this.latitude = lat;
		this.longitude = long;
	},
  lat: function() {
    return this.latitude;
  },
  lng: function() {
    return this.longitude;
  }

};

GLatLngBounds = Class.create();
GLatLngBounds.prototype = {
	initialize: function(sw, ne) {
		this.sw = sw;
		this.ne = ne;
	}
}

GxMarker = Class.create();
GxMarker.prototype = {
	initialize: function(point, icon, title) {
		this.point = point;
		this.icon = icon;
		this.title = title;
		this.registeredEventListeners = {};
		this.infoWindowHtml = null;
	},
	
	click: function() {
		if (this.registeredEventListeners['click'] != null) {
			this.registeredEventListeners['click'](this);
		}
	},
	
	openInfoWindowHtml: function(html) {
    this.infoWindowHtml = html;
	},
	
	isInfoWindowOpen: function() {
		return (this.infoWindowHtml != null);
	}
}

G_MAP_TYPE = "G_MAP_TYPE";
G_SATELLITE_TYPE = "G_SATELLITE_TYPE";
G_HYBRID_TYPE = "G_HYBRID_TYPE";

GSmallZoomControl = Class.create();
GSmallZoomControl.prototype = {
	initialize: function() {}
};

GSmallMapControl = Class.create();
GSmallMapControl.prototype = {
	initialize: function() {}
};

GMapTypeControl = Class.create();
GMapTypeControl.prototype = {
	initialize: function() {}
};

GPoint = Class.create();
GPoint.prototype = {
	initialize: function(x, y) {
		this.x = x;
		this.y = y;
	}
};

GIcon = Class.create();
GIcon.prototype = {
	initialize: function() {
	}
};

GSize = Class.create();
GSize.prototype = {
	initialize: function() {
	}
};

GMarker = Class.create();
GMarker.prototype = {
	initialize: function(point, icon) {
		this.point = point;
		this.icon = icon;
		this.registeredEventListeners = {};
	},
	
	click: function() {
		if (this.registeredEventListeners['click'] != null) {
			this.registeredEventListeners['click'](this);
		}
	},
  getPoint: function() {
    return this.point;
  }

};


GEvent = {
	addListener: function(thingListening, listenedEvent, listenFunction) {
		thingListening.registeredEventListeners[listenedEvent] = listenFunction;
	}
};

