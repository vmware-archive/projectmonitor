var ProjectCheck = function() {
  var projectCheckTimeout = 30 * 1000; // 1 minute

  var currentTimeout;

  var projects = [];

  var makeRequest = function(success) {
    // change JSON request URL to be different from current URL to avoid chrome caching bug
    // http://stackoverflow.com/questions/9956255/chrome-displays-ajax-response-when-pressing-back-button
    $.ajax({
      url: '/?',
      method: 'GET',
      dataType: 'json',
      success: success
    });
  };

  var scheduleRefresh = function() {
    clearTimeout(currentTimeout);
    currentTimeout = setTimeout(ProjectCheck.checkProjects, projectCheckTimeout);
  };

  return {
    init: function() {
      makeRequest(function(data) {
        projects = data;
      });
      scheduleRefresh();
    },

    checkProjects: function() {
      makeRequest(function(data) {
        if (!_.isEqual(data, projects)) {
          ProjectMonitor.Window.reload();
        }
        scheduleRefresh();
      });
    }
  };
}();
