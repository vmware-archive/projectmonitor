var Refresher = (function (options) {
  for (var key in options) {
    if (options.hasOwnProperty(key)) {
      this[key] = options[key];
    }
  }

  var pollIntervalSeconds = 30, timeoutFunction;
  var self = this;

  var $tile = $(this.selector);

  this.start = function () {
    timeoutFunction = setTimeout(this.refresh, pollIntervalSeconds * 1000);
  };

  this.refresh = function () {
    $.ajax({
      url: self.url,
      timeout: (pollIntervalSeconds - 1) * 1000,
      success: self.processResponse,
      error: function(x,y,z) {
        // only display unreachable error when external service unreachable
      }
    });
    timeoutFunction = setTimeout(self.refresh, pollIntervalSeconds * 1000);
  };

  this.cleanupTimeout = function () {
    clearTimeout(timeoutFunction);
  };

  this.markAsGood = function () {
    $tile.slideUp();
  };

  this.markAsImpaired = function () {
    $tile.find('a').text(this.name + " IS IMPAIRED");
    this.clearStatuses();
    $tile.addClass('impaired');
    $tile.slideDown();
  };

  this.markAsUnreachable = function () {
    $tile.find('a').text(this.name + " IS UNREACHABLE");
    this.clearStatuses();
    $tile.addClass('unreachable');
    $tile.slideDown();
  };

  this.markAsBroken = function () {
    $tile.find('a').text("CANNOT PARSE " + this.name + " STATUS");
    this.clearStatuses();
    $tile.addClass('broken');
    $tile.slideDown();
  };

  this.clearStatuses = function () {
    $tile.removeClass('unreachable');
    $tile.removeClass('broken');
    $tile.removeClass('impaired')
  }
});
