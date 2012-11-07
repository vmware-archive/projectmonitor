var GithubRefresh = (function () {
  var $githubTile, pollIntervalSeconds = 60, fadeIntervalSeconds = 3;

  return {
    init : function () {
      $githubTile = $('.github');

      if($githubTile.length > 0) {
        setTimeout(this.refresh, pollIntervalSeconds * 1000);
      }
    },

    refresh : function () {
      $.ajax({
        url: '/github_status.json',
        timeout: (pollIntervalSeconds - 1) * 1000,
        success: function(response) {
          var status = response.status;
          if(status == 'good') {
            $githubTile.slideUp();
          }
          else {
            $githubTile.slideDown();
          }
        },
        error: function(x,y,z) {
          $githubTile.slideDown();
        }
      });
      setTimeout(GithubRefresh.refresh, pollIntervalSeconds * 1000);
    }
  };
})();
