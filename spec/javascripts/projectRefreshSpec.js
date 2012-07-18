describe('ProjectRefresh.init', function() {
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
    jasmine.Clock.useMock();
  });

  describe("on a page with 15 projects", function() {
    beforeEach(function() {
      $("body").addClass("dashboard").data("tiles-count", "15");
    });

    it("should call $.get for projects and aggregates", function() {
      ProjectRefresh.init();
      jasmine.Clock.tick(30001);
      expect(ajaxRequests.length).toEqual(4);
      expect(ajaxRequests[0].url).toBe("/projects/1/status?tiles_count=15");
      expect(ajaxRequests[1].url).toBe("/projects/2/status?tiles_count=15");
      expect(ajaxRequests[2].url).toBe("/projects/3/status?tiles_count=15");
      expect(ajaxRequests[3].url).toBe("/aggregate_projects/4/status?tiles_count=15");
    });
  });

  describe("on a page with 48 projects", function() {
    beforeEach(function() {
      $("body").addClass("dashboard").data("tiles-count", "48");
    });

    it("should send the correct number of projects", function() {
      ProjectRefresh.init();
      jasmine.Clock.tick(30001);
      expect(ajaxRequests[0].url).toBe("/projects/1/status?tiles_count=48");
    });
  });

  describe("when a request succeeds", function() {
    beforeEach(function() {
      ProjectRefresh.init();
      jasmine.Clock.tick(30001);
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
      ProjectRefresh.init();
      jasmine.Clock.tick(30001);
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

