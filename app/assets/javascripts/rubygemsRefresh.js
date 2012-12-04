var RubyGemsRefresh = (function () {
  var $githubTile, pollIntervalSeconds = 30, fadeIntervalSeconds = 3, timeoutFunction;

  return {
    init : function () {
      $rubygemsTile = $('.rubygems');

      timeoutFunction = setTimeout(this.refresh, pollIntervalSeconds * 1000);
    },

    refresh : function () {
      $.ajax({
        url: '/rubygems_status.json',
        timeout: 2000,
        success: function(response) {
      var status = response.status;
      if(status == 'bad') {
        RubyGemsRefresh.markAsDown();
      }
      else if(status == 'good') {
        $rubygemsTile.slideUp();
      }
      else if(status == 'page broken') {
        RubyGemsRefresh.markAsBroken();
      }
      else {
        RubyGemsRefresh.markAsUnreachable();
      }
        },
        error: function(x,y,z) {
          RubyGemsRefresh.markAsUnreachable();
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
