var BacktraceHide = {};
(function(o) {
  o.init = function () {
    $('#showTrace').click(function () {
      $('.backtrace').removeClass('hide');
      $('#showTrace').addClass('hide');
    });

    $('#hideTrace').click(function () {
      $('.backtrace').addClass('hide');
      $('#showTrace').removeClass('hide');
    });
  };
})(BacktraceHide);
