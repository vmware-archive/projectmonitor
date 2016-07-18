var RubyGemsRefresh = (function () {
  var refresher;
  var failureThreshold = 4, failureCount = 0;

  return {
    init: function () {
      refresher = new Refresher({
        name: 'RUBYGEMS',
        selector: '.rubygems',
        url: '/rubygems_status.json',
        processResponse: function (response) {
          var status = response.status;
          if (status == 'none') {
            refresher.markAsGood();
            failureCount = 0;
          }
          else {
            failureCount++;
            if (failureCount >= failureThreshold) {
              if (status == 'unreachable') {
                refresher.markAsUnreachable();
              } else if (status == 'page broken') {
                refresher.markAsBroken();
              } else {
                refresher.markAsImpaired();
              }
            }
          }
        }
      });
      refresher.start();
    },

    cleanupTimeout: function () {
      refresher.cleanupTimeout();
    }
  };
})();
