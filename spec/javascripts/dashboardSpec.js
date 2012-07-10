describe('dashboard', function() {
  beforeEach(function() {
    var fixtures = [
      "<ul class='projects'>",
        "<li class='project success' id='project_1' data-id='1'>",
          "<div class='building-indicator'></div>",
        "</li>",
      "</ul>"
    ].join("\n");
    setFixtures(fixtures);
    $("body").addClass("dashboard").addClass("tiles_15");
  });

  it("should create a spinner", function() {
    expect($('.spinner').length).toEqual(0);

    var projectsCount = 48;
    $('.building-indicator').setSpinner(projectsCount);

    expect($('.spinner').length).toEqual(1);
  });
});

