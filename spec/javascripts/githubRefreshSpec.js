describe('GithubRefresh.init', function() {
  beforeEach(function() {
    var fixtures = [
      "<div class='github' style='display: none;'>",
      "</div>"
    ].join("\n");
    setFixtures(fixtures);
    jasmine.clock().install();
    jasmine.Ajax.install();
  });

  afterEach(function() {
    GithubRefresh.cleanupTimeout();
    jasmine.clock().uninstall();
    jasmine.Ajax.uninstall();
  });

  describe("when the status is bad", function() {
    it("shows the github notification", function() {
      GithubRefresh.init();
      expect($(".github")).toBeHidden();

      for (var i=0; i < 4; i++) {
        jasmine.clock().tick(30001);
        jasmine.Ajax.requests.mostRecent().response({
          status: 200,
          responseText: "{\"status\": \"bad\"}"
        });
      }
      expect($(".github")).toBeVisible();
      expect($(".github")).toHaveClass('bad');
    });
  });

  describe("when the status is good", function() {
    it("hides the github notification", function() {
      GithubRefresh.init();
      $(".github").show()

      jasmine.clock().tick(30001);
      jasmine.Ajax.requests.mostRecent().response({
        status: 200,
        responseText: "{\"status\": \"good\"}"
      });
      expect($(".github")).toBeHidden();
    });
  });

  describe("when the status is unreachable", function() {
    it("hides the github notification", function() {
      GithubRefresh.init();
      $(".github").show()

      for (var i=0; i < 4; i++) {
        jasmine.clock().tick(30001);
        jasmine.Ajax.requests.mostRecent().response({
          status: 200,
          responseText: "{\"status\": \"unreachable\"}"
        });
      }
      expect($(".github")).toBeVisible();
      expect($(".github")).toHaveClass('unreachable');
    });
  });
});

