var GithubRefresh = (function () {
  var refresher;
  var failureThreshold = 4, failureCount = 0;

  return {
    init: function () {
      refresher = new Refresher({
        name: 'GITHUB',
        selector: '.github',
        url: '/github_status.json',
        processResponse: function (response) {
          var status = response.status;
          if (status == 'good') {
            refresher.markAsGood();
            failureCount = 0;
          }
          else {
            failureCount++;
            if (failureCount >= failureThreshold) {
              if (status == 'unreachable') {
                refresher.markAsUnreachable();
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
