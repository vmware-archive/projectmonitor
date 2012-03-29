var Application = {};
(function() {
  function timeLeft() {
    if (!isNaN(timeLeftSec) && timeLeftSec > 0) {
      timeSpan.text(timeLeftSec-- + " seconds");
    } else {
      clearInterval(timeLeftInterval);
      timeSpan.text('ASAP');
    }
  }
  Application.startTimer = function() {
    timeSpan = jQuery('#time_left');
    timeLeftSec = parseInt(timeSpan.text());

    timeLeftInterval = setInterval(function() {
      timeLeft();
    }, 1000);
  };

  jQuery(document).ready(function() {
    Application.startTimer();
  })
})();
