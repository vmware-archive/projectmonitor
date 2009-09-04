// Test: is it read-only?
// Ajax Request mock
ActiveAjaxRequests = {};
ActiveAjaxRequestKeys = [];
SynchronousResponses = {};

AjaxRequests = {
	numActive: 0,
	reset: function() {
		ActiveAjaxRequests = {};
    ActiveAjaxRequestKeys = [];
    this.numActive = 0;
	},
	
	addRequest: function(url, request) {
		ActiveAjaxRequests[url] = request;
    ActiveAjaxRequestKeys.push(url);
    ++this.numActive;
	},
	
	dropRequest: function(url) {
    ActiveAjaxRequests[url] = undefined;
    ActiveAjaxRequestKeys = ActiveAjaxRequestKeys.reject(function(key) {return key == url});
    --this.numActive;
	},

  setupSynchronousResponse: function(url, expectedResponse) {
    SynchronousResponses[url] = expectedResponse;
  }
};

Ajax.Request = Class.create();
Ajax.Updater = Class.create();

Ajax.Updater.prototype = {
	initialize: function(elementToUpdateId, url, options) {
		this.elementToUpdate = $(elementToUpdateId);
		this.url = url;
		this.options = options;
    this.isSuccess = true;  // why isn't this false?
    AjaxRequests.addRequest(url, this);
	},

	simulateSuccess: function(responseText) {
    this.isSuccess = true;
		AjaxRequests.dropRequest(this.url);
		var myResponse = {responseText: responseText};
    this.elementToUpdate.innerHTML = myResponse.responseText;
    if (this.options['onSuccess']) {
			this.options['onSuccess'](myResponse);
		}
		if (this.options['onComplete']) {
			this.options['onComplete'](myResponse);
		}
	},

	simulateFailure: function(responseText) {
    this.isSuccess = false;
		AjaxRequests.dropRequest(this.url);
		var myResponse = {responseText: responseText};
		if (this.options['onFailure']) {
			this.options['onFailure'](myResponse);
		}
  },

  simulateException: function(exception) {
    this.isSuccess = false;
    AjaxRequests.dropRequest(this.url);
		if (this.options['onException']) {
			this.options['onException'](this, exception);
		}
  },

  responseIsSuccess: function() {
    return this.isSuccess;
  },

  responseIsFailure: function() {
    return !this.responseIsSuccess();
  }
};


Ajax.Request.prototype = {
	initialize: function(url, options) {
		this.url = url;
		this.options = options;
    this.isSuccess = true;
    this.aborted = false;
    AjaxRequests.addRequest(url, this);
		
		if (this.options['onLoading']) {
			this.options['onLoading'](this);
		}

    this.firefoxOnFailureBug = false;
    if (options.asynchronous == false) {
      this.handleSynchronousResponse();
    }
    this._setTransport();
  },

  handleSynchronousResponse: function() {
    var synchResponse = SynchronousResponses[this.url];
    if (synchResponse) {
      AjaxRequests.dropRequest(this.url);
      this.transport = {responseText: synchResponse};
    } else {
      throw("Set up what response you want in this test with AjaxRequests.setupSynchronousResponse for " + this.url);
    }
  },

  simulateSuccess: function(responseText) {
    this.isSuccess = true;
		AjaxRequests.dropRequest(this.url);
		var myResponse = {responseText: responseText};
		if (this.options['onLoaded']) {
			this.options['onLoaded'](this);
		}

		this.callOnComplete(myResponse);

    if (this.options['onSuccess']) {
			this.options['onSuccess'](myResponse);
		}

	},

  callOnComplete: function(myResponse) {
    this.transport = null;
    if (this.options['onComplete']) {
			this.options['onComplete'](myResponse);
		}
  },

  simulateFailure: function(responseText) {
    this.isSuccess = false;
		AjaxRequests.dropRequest(this.url);
		var myResponse = {responseText: responseText};

    this.callOnComplete(myResponse);

    if (!this.firefoxOnFailureBug && this.options['onFailure']) {
			this.options['onFailure'](myResponse);
		}
	},

  simulateConnectivityFailure: function(responseText) {
    this.isSuccess = false;
		AjaxRequests.dropRequest(this.url);
		var myResponse = {responseText: responseText};

    this.callOnComplete(myResponse);

    if (!this.firefoxOnFailureBug && this.options['onConnectivityFailure']) {
			this.options['onConnectivityFailure'](myResponse);
		}
	},

  simulateException: function(exception) {
    this.isSuccess = false;
    AjaxRequests.dropRequest(this.url);
		if (this.options['onException']) {
			this.options['onException'](this, exception);
		}
    this.transport = null;
  },

  simulateRedirect: function(status) {
    this.isSuccess = false;
    AjaxRequests.dropRequest(this.url);
    var response = { status: status };
    if (this.options["on" + status]) {
      this.options["on" + status](response);
    }
  },

  responseIsSuccess: function() {
    if (!this.isSuccess && this.firefoxOnFailureBug) {
      throw "calling this method where there's an actual failure blows up in Firefox"
    } else {
      return this.isSuccess;
    }
  },

  responseIsFailure: function() {
    return !this.responseIsSuccess();
  },

  _setTransport: function() {
    abortFunction = function() {
      this.aborted = true;
    }.bind(this);
    
    this.transport = {
      abort: abortFunction
    };
  }

};

function getActiveAjaxRequest(requestUrl) {
	return ActiveAjaxRequests[requestUrl];
}

function getActiveAjaxRequestByIndex(index) {
  return ActiveAjaxRequests[ActiveAjaxRequestKeys[index]];
}

function assertActiveAjaxRequest(requestUrl, message) {
	if (message == null) {message = "";}
	assertNotUndefined("Could not find ajax request " + requestUrl + "\n" + message,
		ActiveAjaxRequests[requestUrl]);
}

function assertNoActiveAjaxRequest(requestUrl, message) {
	if (message == null) {message = "";}
	assertUndefined("Found active AJAX request for " + requestUrl + "\n" + message, 
		ActiveAjaxRequests[requestUrl]);
}
