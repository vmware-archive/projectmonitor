describe('GithubRefresh.init', function () {

  function expectOneFormattingClass() {
    var github = $(".github")
    var classCount = (github.hasClass('bad') ? 1 : 0) +
      (github.hasClass('unreachable') ? 1 : 0) +
      (github.hasClass('impaired') ? 1 : 0);
    expect(classCount).toBe(1);
  };

  beforeEach(function () {
    var fixtures = [
      "<div class='github impaired' style='display: none;'>",
      "<a></a>",
      "</div>"
    ].join("\n");
    setFixtures(fixtures);
    jasmine.clock().install();
    jasmine.Ajax.install();
  });

  afterEach(function () {
    GithubRefresh.cleanupTimeout();
    jasmine.clock().uninstall();
    jasmine.Ajax.uninstall();
  });

  describe("when the status is bad", function () {
    it("shows the github notification", function () {
      GithubRefresh.init();
      expect($(".github")).toBeHidden();

      for (var i = 0; i < 4; i++) {
        jasmine.clock().tick(30001);
        jasmine.Ajax.requests.mostRecent().response({
          status: 200,
          responseText: "{\"status\": \"bad\"}"
        });
      }
      expect($(".github")).toBeVisible();
      expect($(".github").find('a').text()).toEqual('GITHUB IS DOWN');
      expect($(".github")).toHaveClass('bad');
      expectOneFormattingClass();
    });
  });

  describe("when the status is good", function () {
    it("hides the github notification", function () {
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

  describe("when the status is unreachable", function () {
    it("shows the github notification, sets the text and sets the unreachable class", function () {
      GithubRefresh.init();
      $(".github").show()

      for (var i = 0; i < 4; i++) {
        jasmine.clock().tick(30001);
        jasmine.Ajax.requests.mostRecent().response({
          status: 200,
          responseText: "{\"status\": \"unreachable\"}"
        });
      }
      expect($(".github")).toBeVisible();
      expect($(".github").find('a').text()).toEqual('GITHUB IS UNREACHABLE');
      expect($(".github")).toHaveClass('unreachable');
      expectOneFormattingClass();
    });
  });

  describe("when the status is minor", function () {
    it("shows the github notification, sets the text to impaired and sets the minor class", function () {
      GithubRefresh.init();
      $(".github").show()

      for (var i = 0; i < 4; i++) {
        jasmine.clock().tick(30001);
        jasmine.Ajax.requests.mostRecent().response({
          status: 200,
          responseText: "{\"status\": \"minor\"}"
        });
      }
      expect($(".github")).toBeVisible();
      expect($(".github").find('a').text()).toEqual('GITHUB IS IMPAIRED');
      expect($(".github")).toHaveClass('impaired');
      expectOneFormattingClass();
    });
  });
});

