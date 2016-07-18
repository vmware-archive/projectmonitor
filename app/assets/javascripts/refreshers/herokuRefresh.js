var HerokuRefresh = (function () {
  var refresher;
  var failureThreshold = 4, failureCount = 0;

  return {
    init: function () {
      refresher = new Refresher({
        name: 'HEROKU',
        selector: '.heroku',
        url: '/heroku_status.json',
        processResponse: function (response) {
          var status = response.status;
          if (status == 'unreachable') {
            failureCount++;
            if (failureCount >= failureThreshold) {
              refresher.markAsUnreachable();
            }
          }
          else if (status.Development == 'green' && status.Production == 'green') {
            refresher.markAsGood();
            failureCount = 0;
          }
          else {
            failureCount++;
            if (failureCount >= failureThreshold) {
              refresher.markAsImpaired();
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
