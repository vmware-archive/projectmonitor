describe('TagSwitcher.init', function() {
  beforeEach(function() {
    var fixtures = [
      '<input id="current_tag" type="hidden" value="boulder">',
      '<select id="tag" name="tag"><option value=""></option>',
      '<option value="nyc">nyc</option>',
      '<option value="sf">sf</option>',
      '<option value="boulder">boulder</option>',
      '<option value="garbage">garbage</option></select>'
    ].join("\n");
    setFixtures(fixtures);
  });

  describe("when initialized with a chosen tag", function() {
    it("sets the value on the dropdown", function() {
      TagSwitcher.init();
      expect($('#tag').val()).toEqual('boulder')
    });
  });

  describe("when a tag is chosen", function() {
    it("redirects to configuration with tags", function() {
      TagSwitcher.init();
      spyOn(TagSwitcher, "doRedirect");
      $('#tag').val('nyc');
      $('#tag').trigger('change');
      expect(TagSwitcher.doRedirect).toHaveBeenCalledWith('?tags=nyc');
    });
  });

  describe("when the empty tag is chosen", function() {
    it("redirects to base url", function() {
      TagSwitcher.init();
      spyOn(TagSwitcher, "doRedirect");
      $('#tag').val('');
      $('#tag').trigger('change');
      expect(TagSwitcher.doRedirect).toHaveBeenCalledWith('');
    });
  });
});
