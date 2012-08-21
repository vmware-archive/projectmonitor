describe("backtrace show/hide", function() {
  beforeEach(function() {
    var fixtures = "<div class='backtrace hide'>back trace!<a href='#' id='hideTrace'>Hide</a></div><a id='showTrace' href='#'>Show more</a>"
    setFixtures(fixtures);
    BacktraceHide.init();
  });

  it("should show the back trace", function() {
    $('#showTrace').click();
    expect($('.backtrace')).not.toHaveClass('hide');
    expect($('#showTrace')).toHaveClass('hide');
    $('#hideTrace').click();
    expect($('.backtrace')).toHaveClass('hide');
    expect($('#showTrace')).not.toHaveClass('hide');
  });
});
