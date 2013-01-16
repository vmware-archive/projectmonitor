var HerokuRefresh = (function () {
  var $herokuTile, failureThreshold = 4, failureCount = 0;
  var pollIntervalSeconds = 30, fadeIntervalSeconds = 3, timeoutFunction;

  return {
    init : function () {
      $herokuTile = $('.heroku');

      timeoutFunction = setTimeout(this.refresh, pollIntervalSeconds * 1000);
    },

    refresh : function () {
      $.ajax({
        url: '/heroku_status.json',
        timeout: (pollIntervalSeconds - 1) * 1000,
        success: function(response) {
          var status = response.status;
          if(status == 'unreachable') {
            failureCount++;
            if (failureCount >= failureThreshold) {
              HerokuRefresh.markAsUnreachable();
            }
          }
          else if(status.Development == 'green' && status.Production == 'green') {
            $herokuTile.slideUp();
            failureCount = 0;
          }
          else {
            failureCount++;
            if (failureCount >= failureThreshold) {
              HerokuRefresh.markAsDown();
            }
          }
        },
        error: function(x,y,z) {
          HerokuRefresh.markAsUnreachable();
        }
      });
      timeoutFunction = setTimeout(HerokuRefresh.refresh, pollIntervalSeconds * 1000);
    },

    cleanupTimeout : function () {
      clearTimeout(timeoutFunction);
    },

    markAsUnreachable: function () {
      $herokuTile.find('a').text("HEROKU IS UNREACHABLE");
      $herokuTile.removeClass('bad');
      $herokuTile.addClass('unreachable');
      $herokuTile.slideDown();
    },

    markAsDown: function () {
      $herokuTile.find('a').text("HEROKU IS DOWN");
      $herokuTile.removeClass('unreachable');
      $herokuTile.addClass('bad');
      $herokuTile.slideDown();
    }
  };
})();
