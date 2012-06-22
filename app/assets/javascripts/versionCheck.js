var VersionCheck = function() {
  var versionCheckTimeout = 60 * 1000; // 1 minute

  var currentTimeout;

  var versionRequest = function(success) {
    $.ajax({
      url: '/version',
      method: 'GET',
      success: success
    });
  };

  var scheduleRefresh = function() {
    clearTimeout(currentTimeout);
    currentTimeout = setTimeout(VersionCheck.checkVersion, versionCheckTimeout);
  };

  return {
    init: function() {
      versionRequest(function(response) {
        window.currentVersion = response;
      });
      scheduleRefresh();
    },

    checkVersion: function() {
      versionRequest(function(response) {
        if (response != window.currentVersion) {
          ProjectMonitor.Window.reload();
        }
      });
      scheduleRefresh();
    },

    currentVersion: function() {
      return window.currentVersion;
    }
  };
}();
