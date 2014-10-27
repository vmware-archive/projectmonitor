describe('HerokuRefresh.init', function() {
  beforeEach(function() {
    var fixtures = [
      "<div class='heroku' style='display: none;'>",
      "</div>"
    ].join("\n");
    setFixtures(fixtures);
    jasmine.Ajax.install();
    jasmine.clock().install();
  });

  afterEach(function() {
    HerokuRefresh.cleanupTimeout();
    jasmine.clock().uninstall();
    jasmine.Ajax.uninstall();
  });

  describe("when the status is bad", function() {
    it("shows the heroku notification", function() {
      HerokuRefresh.init();
      expect($(".heroku")).toBeHidden();

      for (var i=0; i < 4; i++) {
        jasmine.clock().tick(30001);
        jasmine.Ajax.requests.mostRecent().response({
          status: 200,
          responseText: "{\"status\": \"red\"}"
        });
      }
      expect($(".heroku")).toBeVisible();
      expect($(".heroku")).toHaveClass('bad');
    });
  });

  describe("when the status is green", function() {
    it("hides the heroku notification", function() {
      HerokuRefresh.init();
      $(".heroku").show()

      jasmine.clock().tick(30001);
      jasmine.Ajax.requests.mostRecent().response({
        status: 200,
        responseText: "{\"status\": {\"Development\": \"green\", \"Production\": \"green\"}}"
      });
      expect($(".heroku")).toBeHidden();
    });
  });

  describe("when the status is unreachable", function() {
    it("hides the heroku notification", function() {
      HerokuRefresh.init();
      $(".heroku").show()

      for (var i=0; i < 4; i++) {
        jasmine.clock().tick(30001);
        jasmine.Ajax.requests.mostRecent().response({
          status: 200,
          responseText: "{\"status\": \"unreachable\"}"
        });
      }
      expect($(".heroku")).toBeVisible();
      expect($(".heroku")).toHaveClass('unreachable');
    });
  });
});
