describe('refresh', function() {
  beforeEach(function() {
    var fixtures = [
      "<ul class='projects'>",
        "<li class='project success' id='project_1' data-id='1'></li>",
        "<li class='project failure' id='project_2' data-id='2'></li>",
        "<li class='project failure' id='project_3' data-id='3'></li>",
        "<li class='project aggregate success' id='aggregate_project_4' data-id='4'></li>",
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

  describe("when a requjest comes back", function() {
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

    it("uses the previous items classes", function() {
      expect($("#aggregate_project_4")).toHaveClass("project");
      expect($("#aggregate_project_4")).toHaveClass("aggregate");
      expect($("#aggregate_project_4")).toHaveClass("success");
      expect($("#aggregate_project_4")).not.toHaveClass("grid_4");
    });
  });
});

describe('polling indicator', function(){
  beforeEach(function() {
    var fixtures = [
      "<ul class='projects'>",
        "<li class='project success' id='project_1' data-id='1'></li>",
        "<li class='project failure' id='project_2' data-id='2'></li>",
        "<li class='project failure' id='project_3' data-id='3'></li>",
        "<li class='project aggregate success' id='aggregate_project_4' data-id='4'></li>",
      "</ul>",
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
      refresh();
    });

    it("should show the indicator", function() {
      expect($("#indicator")).not.toHaveClass('idle');
    });

    describe("when one project has finished polling", function() {
      beforeEach(function() {
        refreshComplete({responseText: 'success'});
      });

      it("should show the indicator", function() {
        expect($("#indicator")).not.toHaveClass('idle');
      });

      describe("when one project has finished polling", function() {
        beforeEach(function() {
          refreshComplete({responseText: 'success'});
          refreshComplete({responseText: 'success'});
          refreshComplete({responseText: 'success'});
        });

        it("should hide the indicator", function() {
          expect($("#indicator")).toHaveClass('idle');
        });
      });
    });
  });
});
