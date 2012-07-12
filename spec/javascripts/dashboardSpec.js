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
