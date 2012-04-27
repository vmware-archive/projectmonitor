describe('refresh', function() {
  beforeEach(function() {
    var fixtures = [
      "<ul class='projects'>",
        "<li class='project success' id='project_1' data-id='1'></li>",
        "<li class='project failure' id='project_2' data-id='2'></li>",
        "<li class='project failure' id='project_3' data-id='3'></li>",
        "<li class='project aggregate success' id='aggregate_project_4' data-id='4'>Aggregate Project</li>",
      "</ul>"
    ].join("\n");
    setFixtures(fixtures);
  });

  it("should call $.get for projects and aggregates", function() {
    refresh();

    expect(ajaxRequests.length).toEqual(4);
    expect(ajaxRequests[0].url).toBe("/projects/1/status");
    expect(ajaxRequests[1].url).toBe("/projects/2/status");
    expect(ajaxRequests[2].url).toBe("/projects/3/status");
    expect(ajaxRequests[3].url).toBe("/aggregate_projects/4/status");
  });

  describe("when a request succeeds", function() {
    beforeEach(function() {
      refresh();
      mostRecentAjaxRequest().response({
        status: 200,
        responseText: "<li class='grid_4' id='aggregate_project_4' data-id='4'>Hello World</li>"
      });
    });

    it("replaces the correct DOM element", function() {
      expect($("#aggregate_project_4").text()).toContain("Hello World");
    });
  });

  describe("when a request fails", function() {
    beforeEach(function() {
      refresh();
      mostRecentAjaxRequest().response({
        status: 500,
        responseText: "Whoops!  An error occurred!"
      });
    });

    it("leaves the contents of the element alone", function() {
      expect($("#aggregate_project_4").text()).toContain("Aggregate Project");
    });

    it("adds the 'server-unreachable' class to the element", function() {
      expect($("#aggregate_project_4")).toHaveClass("success");
      expect($("#aggregate_project_4")).toHaveClass("server-unreachable");
    });
  });
});

describe('polling indicator', function(){
  beforeEach(function() {
    var fixtures = [
      "<div id='indicator' class='idle'>",
        "<img/>",
      "</div>"
    ].join("\n");
    setFixtures(fixtures);
  });

  it("should have an image", function() {
    expect($("#indicator img")).toExist();
  });

  it("should hide the indicator", function() {
    expect($("#indicator")).toHaveClass('idle');
  });

  describe("when polling", function() {

    beforeEach(function() {
      $(document).trigger("ajaxStart");
    });

    it("should show the indicator", function() {
      expect($("#indicator")).not.toHaveClass('idle');
    });

    describe("when all projects have finished polling", function() {
      beforeEach(function() {
        $(document).trigger("ajaxStop");
      });

      it("should not show the indicator", function() {
        expect($("#indicator")).toHaveClass('idle');
      });
    });
  });
});
