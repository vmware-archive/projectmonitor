describe("backtrace show/hide", function() {
  beforeEach(function() {
    var fixtures = "<div>" +
                      "<div class='backtrace hide' id='b1'>back trace!" +
                        "<a href='#' class='hideTrace' id='h1'>Hide</a>" +
                      "</div><a class='showTrace' id='s1' href='#'>Show more</a>" +
                   "</div><div>" +
                      "<div class='backtrace hide' id='b2'>back trace!" +
                        "<a href='#' class='hideTrace' id='h2'>Hide</a>" +
                      "</div><a class='showTrace' id='s2' href='#'>Show more</a>" +
                    "</div>";
    setFixtures(fixtures);
    BacktraceHide.init();
  });

  it("should show the back trace", function() {
    $('.showTrace#s1').click();

    expect($('.backtrace#b1')).not.toHaveClass('hide');
    expect($('.backtrace#b2')).toHaveClass('hide');

    expect($('.showTrace#s1')).toHaveClass('hide');
    expect($('.showTrace#s2')).not.toHaveClass('hide');

    $('.hideTrace#h1').click();

    expect($('.backtrace#b1')).toHaveClass('hide');
    expect($('.showTrace#s1')).not.toHaveClass('hide');
  });
});
