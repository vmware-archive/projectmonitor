describe('HerokuRefresh.init', function() {
  beforeEach(function() {
    var fixtures = [
      "<div class='heroku' style='display: none;'>",
      "</div>"
    ].join("\n");
    setFixtures(fixtures);
    jasmine.Clock.useMock();
  });

  afterEach(function() {
    HerokuRefresh.cleanupTimeout();
  });

  describe("when the status is bad", function() {
    it("shows the heroku notification", function() {
      HerokuRefresh.init();
      expect($(".heroku")).toBeHidden();

      jasmine.Clock.tick(30001);
      mostRecentAjaxRequest().response({
        status: 200,
        responseText: "{\"status\": \"red\"}"
      });
      expect($(".heroku")).toBeVisible();
      expect($(".heroku")).toHaveClass('bad');
    });
  });

  describe("when the status is green", function() {
    it("hides the heroku notification", function() {
      spyOn($.fn, "slideUp").andCallFake(function(){
        this.hide();
      })
      HerokuRefresh.init();
      $(".heroku").show()

      jasmine.Clock.tick(30001);
      mostRecentAjaxRequest().response({
        status: 200,
        responseText: "{\"status\": {\"Development\": \"green\", \"Production\": \"green\"}}"
      });
      expect($(".heroku")).toBeHidden();
    });
  });

  describe("when the status is unreachable", function() {
    it("hides the heroku notification", function() {
      spyOn($.fn, "slideUp").andCallFake(function(){
        this.hide();
      })
      HerokuRefresh.init();
      $(".heroku").show()

      jasmine.Clock.tick(30001);
      mostRecentAjaxRequest().response({
        status: 200,
        responseText: "{\"status\": \"unreachable\"}"
      });
      expect($(".heroku")).toBeVisible();
      expect($(".heroku")).toHaveClass('unreachable');
    });
  });
});

