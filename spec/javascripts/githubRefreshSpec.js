describe('GithubRefresh.init', function() {
  beforeEach(function() {
    var fixtures = [
      "<div class='github' style='display: none;'>",
      "</div>"
    ].join("\n");
    setFixtures(fixtures);
    jasmine.Clock.useMock();
  });

  describe("when the status is bad", function() {
    it("shows the github notification", function() {
      GithubRefresh.init();
      expect($(".github")).toBeHidden();

      jasmine.Clock.tick(60001);
      mostRecentAjaxRequest().response({
        status: 200,
        responseText: "{\"status\": \"bad\"}"
      });
      expect($(".github")).toBeVisible();
    });
  });

  describe("when the status is good", function() {
    it("hides the github notification", function() {
      spyOn($.fn, "slideUp").andCallFake(function(){
        this.hide();
      })
      GithubRefresh.init();
      $(".github").show()

      jasmine.Clock.tick(60001);
      mostRecentAjaxRequest().response({
        status: 200,
        responseText: "{\"status\": \"good\"}"
      });
      expect($(".github")).toBeHidden();
    });
  });
});

