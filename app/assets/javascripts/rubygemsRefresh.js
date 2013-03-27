var RubyGemsRefresh = (function () {
  var $rubygemsTile, failureThreshold = 4, failureCount = 0;
  var pollIntervalSeconds = 30, timeoutFunction;

  return {
    init : function () {
      $rubygemsTile = $('.rubygems');

      timeoutFunction = setTimeout(this.refresh, pollIntervalSeconds * 1000);
    },

    refresh : function () {
      $.ajax({
        url: '/rubygems_status.json',
        timeout: (pollIntervalSeconds - 1) * 1000,
        success: function(response) {
          var status = response.status;
          if(status == 'good') {
            $rubygemsTile.slideUp();
            failureCount = 0;
          }
          else {
            failureCount++;
            if (failureCount >= failureThreshold) {
              if (status == 'bad') {
                RubyGemsRefresh.markAsDown();
              }
              else if(status == 'page broken') {
                RubyGemsRefresh.markAsBroken();
              }
              else {
                RubyGemsRefresh.markAsUnreachable();
              }
            }
          }
        },
        error: function(x,y,z) {
          // only display unreachable error when external service unreachable
        }
      });
      timeoutFunction = setTimeout(RubyGemsRefresh.refresh, pollIntervalSeconds * 1000);
    },

    cleanupTimeout : function () {
      clearTimeout(timeoutFunction);
    },

    markAsUnreachable: function () {
      $rubygemsTile.find('a').text("RUBYGEMS IS UNREACHABLE");
      RubyGemsRefresh.clearStatuses();
      $rubygemsTile.addClass('unreachable');
      $rubygemsTile.slideDown();
    },

    markAsDown: function () {
      $rubygemsTile.find('a').text("RUBYGEMS IS DOWN");
      RubyGemsRefresh.clearStatuses();
      $rubygemsTile.addClass('bad');
      $rubygemsTile.slideDown();
    },

    markAsBroken: function () {
      $rubygemsTile.find('a').text("CANNOT PARSE RUBYGEMS STATUS");
      RubyGemsRefresh.clearStatuses();
      $rubygemsTile.addClass('broken');
      $rubygemsTile.slideDown();
    },

    clearStatuses: function () {
      $rubygemsTile.removeClass('unreachable');
      $rubygemsTile.removeClass('bad');
      $rubygemsTile.removeClass('broken');
    }
  };
})();
