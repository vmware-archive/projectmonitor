var ProjectCheck = function() {
  var projectCheckTimeout = 30 * 1000; // 1 minute

  var currentTimeout;

  var projects = [];

  var makeRequest = function(success) {
    $.ajax({
      url: '/',
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
