(function($) {
  var ajax = $.ajax;
  $(Screw).bind('after', function() {
    var error_text = $(".error").map(function(i, element) {
      return element.innerHTML;
    }).get().join("\n");

    var suite_id;
    if(top.runOptions) {
      suite_id = top.runOptions.getSessionId();
    } else {
      suite_id = 'user';
    }

    ajax({
      type: "POST",
      url: '/suites/' + suite_id + '/finish',
      data: {"text": error_text}
    });
  });
})(jQuery);
