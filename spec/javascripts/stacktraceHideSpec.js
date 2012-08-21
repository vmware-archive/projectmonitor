describe("stacktrace show/hide", function() {
  beforeEach(function() {
    var fixtures = "<div class='stacktrace hide'>Stack trace!<a href='#' id='hideTrace'>Hide</a></div><a id='showTrace' href='#'>Show more</a>"
    setFixtures(fixtures);
    StacktraceHide.init();
  });

  it("should show the stack trace", function() {
    $('#showTrace').click();
    expect($('.stacktrace')).not.toHaveClass('hide');
    expect($('#showTrace')).toHaveClass('hide');
    $('#hideTrace').click();
    expect($('.stacktrace')).toHaveClass('hide');
    expect($('#showTrace')).not.toHaveClass('hide');
  });
});
