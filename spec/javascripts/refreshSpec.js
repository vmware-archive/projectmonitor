describe('refresh', function() {
  beforeEach(function() {
    var fixtures = [
      "<ul class='projects'>",
        "<li class='project success' id='project_1' data-id='1'></li>",
        "<li class='project failure' id='project_2' data-id='2'></li>",
        "<li class='project failure' id='project_3' data-id='3'></li>",
        "<li class='project aggregate success' id='project_4' data-id='4'></li>",
      "</ul>"
    ].join("\n");
    setFixtures(fixtures);
  });

  afterEach(function(){
    $.ajax.reset();
  });

  it("should call $.get for projects and aggregates", function() {
    var spyOnGet = spyOn(jQuery, "ajax");

    refresh();

    expect(spyOnGet).toHaveBeenCalled();
    expect(spyOnGet.argsForCall[0][0].url).toBe("/projects/1/status");
    expect(spyOnGet.argsForCall[1][0].url).toBe("/projects/2/status");
    expect(spyOnGet.argsForCall[2][0].url).toBe("/projects/3/status");
    expect(spyOnGet.argsForCall[3][0].url).toBe("/aggregate_projects/4/status");
  });
});
