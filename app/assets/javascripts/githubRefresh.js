var GithubRefresh = (function () {
  var $githubTile, pollIntervalSeconds = 30, fadeIntervalSeconds = 3, timeoutFunction;

  return {
    init : function () {
      $githubTile = $('.github');

      timeoutFunction = setTimeout(this.refresh, pollIntervalSeconds * 1000);
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
          else if(status == 'unreachable') {
            GithubRefresh.markAsUnreachable();
          }
          else {
            GithubRefresh.markAsDown();
          }
        },
        error: function(x,y,z) {
          GithubRefresh.markAsUnreachable();
        }
      });
      timeoutFunction = setTimeout(GithubRefresh.refresh, pollIntervalSeconds * 1000);
    },

    cleanupTimeout : function () {
      clearTimeout(timeoutFunction);
    },

    markAsUnreachable: function () {
      $githubTile.find('a').text("GITHUB IS UNREACHABLE");
      $githubTile.removeClass('bad');
      $githubTile.addClass('unreachable');
      $githubTile.slideDown();
    },

    markAsDown: function () {
      $githubTile.find('a').text("GITHUB IS DOWN");
      $githubTile.removeClass('unreachable');
      $githubTile.addClass('bad');
      $githubTile.slideDown();
    }
  };
})();
