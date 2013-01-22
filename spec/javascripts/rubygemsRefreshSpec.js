describe('RubyGemsRefresh.init', function() {
  beforeEach(function() {
    var fixtures = [
      "<div class='rubygems' style='display: none;'>",
      "</div>"
    ].join("\n");
    setFixtures(fixtures);
    jasmine.Clock.useMock();
  });

  afterEach(function() {
    RubyGemsRefresh.cleanupTimeout();
  });

  describe("when the status is bad", function() {
    it("shows the rubygems notification", function() {
      spyOn(RubyGemsRefresh, "clearStatuses");
      RubyGemsRefresh.init();
      expect($(".rubygems")).toBeHidden();

      for (var i=0; i < 4; i++) {
        jasmine.Clock.tick(30001);
        mostRecentAjaxRequest().response({
          status: 200,
          responseText: "{\"status\": \"bad\"}"
        });
      }

      expect($(".rubygems")).toBeVisible();
      expect($(".rubygems")).toHaveClass('bad');
      expect(RubyGemsRefresh.clearStatuses).toHaveBeenCalled();
    });
  });

  describe("when the status is good", function() {
    it("does not show the rubygems notification", function() {
      spyOn($.fn, "slideUp").andCallFake(function(){
            this.hide();
        });
      RubyGemsRefresh.init();
      $(".rubygems").show();

        jasmine.Clock.tick(30001);
          mostRecentAjaxRequest().response({
            status: 200,
            responseText: "{\"status\": \"good\"}"
          });
      expect($(".rubygems")).toBeHidden();
    });
  });

  describe("when rubygems is unreachable", function() {
    it("shows unreachable", function() {
      spyOn(RubyGemsRefresh, "clearStatuses");
      RubyGemsRefresh.init();
      expect($(".rubygems")).toBeHidden();

      for (var i=0; i < 4; i++) {
        jasmine.Clock.tick(30001);
        mostRecentAjaxRequest().response({
          status: 200,
          responseText: "{\"status\": \"unreachable\"}"
        });
      }
      expect($(".rubygems")).toBeVisible();
      expect($(".rubygems")).toHaveClass('unreachable');
      expect(RubyGemsRefresh.clearStatuses).toHaveBeenCalled();
    });
  });

  // marking this disabled, as we removed this functionality in
  // e0d9cdd3720f5f34a292f5ff719483a7a4968bb0
  xdescribe("when our app is unreachable", function() {
    it("shows unreachable", function() {
      spyOn(RubyGemsRefresh, "clearStatuses");
      RubyGemsRefresh.init();
      expect($(".rubygems")).toBeHidden();

        jasmine.Clock.tick(30001);
          mostRecentAjaxRequest().response({
            status: 500,
            responseText: "{}"
          });
      expect($(".rubygems")).toBeVisible();
      expect($(".rubygems")).toHaveClass('unreachable');
      expect(RubyGemsRefresh.clearStatuses).toHaveBeenCalled();
    });
  });

  describe("when page is broken/raises parsing error", function() {
    it("shows page broken error", function() {
      spyOn(RubyGemsRefresh, "clearStatuses");
      RubyGemsRefresh.init();
      expect($(".rubygems")).toBeHidden();

        jasmine.Clock.tick(30001);
          mostRecentAjaxRequest().response({
            status: 200,
            responseText: "{\"status\": \"page broken\"}"
          });

      expect($(".rubygems")).toBeVisible();
      expect($(".rubygems")).toHaveClass('broken');
      expect(RubyGemsRefresh.clearStatuses).toHaveBeenCalled();
    });
  });

});

