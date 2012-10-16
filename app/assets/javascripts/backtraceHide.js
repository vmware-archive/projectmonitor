var BacktraceHide = {};
(function(o) {
  o.init = function () {
    $('.showTrace').click(function () {
      $(this).parent().find('.backtrace').removeClass('hide');
      $(this).parent().find('.showTrace').addClass('hide');
    });

    $('.hideTrace').click(function () {
      id = $($(this).parent()).attr('id').replace('b','s');
      $(this).parent().addClass('hide');
      $(this).parent().parent().find('.showTrace').removeClass('hide');
    });
  };
})(BacktraceHide);
