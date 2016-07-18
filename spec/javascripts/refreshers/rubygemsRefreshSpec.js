describe('RubyGemsRefresh.init', function() {
  beforeEach(function() {
    var fixtures = [
      "<div class='rubygems' style='display: none;'>",
      "</div>"
    ].join("\n");
    setFixtures(fixtures);
    jasmine.clock().install();
    jasmine.Ajax.install();
  });

  afterEach(function() {
    RubyGemsRefresh.cleanupTimeout();
    jasmine.clock().uninstall();
    jasmine.Ajax.uninstall();
  });

  describe("when the status is bad", function() {
    it("shows the rubygems notification", function() {
      RubyGemsRefresh.init();
      expect($(".rubygems")).toBeHidden();

      for (var i=0; i < 4; i++) {
        jasmine.clock().tick(30001);
        jasmine.Ajax.requests.mostRecent().response({
          status: 200,
          responseText: "{\"status\": \"critical\"}"
        });
      }

      expect($(".rubygems")).toBeVisible();
      expect($(".rubygems")).toHaveClass('impaired');
    });
  });

  describe("when the status is none", function() {
    it("does not show the rubygems notification", function() {
      RubyGemsRefresh.init();
      $(".rubygems").show();

      jasmine.clock().tick(30001);
      jasmine.Ajax.requests.mostRecent().response({
        status: 200,
        responseText: "{\"status\": \"none\"}"
      });
      expect($(".rubygems")).toBeHidden();
    });
  });

  describe("when rubygems is unreachable", function() {
    it("shows unreachable", function() {
      RubyGemsRefresh.init();
      expect($(".rubygems")).toBeHidden();

      for (var i=0; i < 4; i++) {
        jasmine.clock().tick(30001);
        jasmine.Ajax.requests.mostRecent().response({
          status: 200,
          responseText: "{\"status\": \"unreachable\"}"
        });
      }
      expect($(".rubygems")).toBeVisible();
      expect($(".rubygems")).toHaveClass('unreachable');
    });
  });

  describe("when rubygems is unparsable", function() {
    it("shows page broken notification", function() {
      RubyGemsRefresh.init();
      expect($(".rubygems")).toBeHidden();

      for (var i=0; i < 4; i++) {
        jasmine.clock().tick(30001);
        jasmine.Ajax.requests.mostRecent().response({
          status: 200,
          responseText: "{\"status\": \"page broken\"}"
        });
      }
      expect($(".rubygems")).toBeVisible();
      expect($(".rubygems")).toHaveClass('broken');
    });
  });

  describe("when page is broken/raises parsing error", function() {
    it("shows page broken error", function() {
      RubyGemsRefresh.init();
      expect($(".rubygems")).toBeHidden();

      jasmine.clock().tick(30001);
      jasmine.Ajax.requests.mostRecent().response({
        status: 200,
        responseText: "{\"status\": \"page broken\"}"
      });

      expect($(".rubygems")).toBeVisible();
      expect($(".rubygems")).toHaveClass('broken');
    });
  });

});
