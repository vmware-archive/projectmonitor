var StacktraceHide = {};
(function(o) {
  o.init = function () {
    $('#showTrace').click(function () {
      $('.stacktrace').removeClass('hide');
      $('#showTrace').addClass('hide');
    });

    $('#hideTrace').click(function () {
      $('.stacktrace').addClass('hide');
      $('#showTrace').removeClass('hide');
    });
  };
})(StacktraceHide);
