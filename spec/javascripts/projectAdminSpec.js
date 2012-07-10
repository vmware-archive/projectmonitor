describe('projectAdmin', function() {
  var travis_example_feed_url = "http://travis-ci.org/[account]/[project]/cc.xml";
  beforeEach(function() {
    var fixtures = [
      "<select id='project_type'>",
      "<option value=''></option>",
      "<option value='TeamCityRestProject'>Team City Rest Project</option>",
      "<option value='TravisProject'>Travis Project</option></select>",
      "<textarea id='project_feed_url'></textarea>"
    ].join("\n");
    setFixtures(fixtures);
  });

  describe('when selecting a Travis project', function() {
    it('adds an example url to the feed URL text area', function() {
      $('#project_type').val('TravisProject');
      $('#project_type').change();
      expect($("#project_feed_url").val()).toEqual(travis_example_feed_url);
    });


    it('does not overwrite exisiting data in the feed url text area', function() {
      $("#project_feed_url").text('Some Other URL')
      $('#project_type').val('TravisProject');
      $('#project_type').change();
      expect($("#project_feed_url").val()).toEqual("Some Other URL");
    });
  });

  describe('when selecting a project other than a Travis project', function() {
    it('does not add an example url to the feed URL text area', function() {
      $('#project_type').val('TeamCityRestProject');
      $('#project_type').change();
      expect($("#project_feed_url").val()).toEqual("");
    });

    it('does not overwrite exisiting data in the feed url text area', function() {
      $("#project_feed_url").text('Some Other URL')
      $('#project_type').val('TeamCityRestProject');
      $('#project_type').change();
      expect($("#project_feed_url").val()).toEqual("Some Other URL");
    });

    it('removes the travis example URL', function(){
      $("#project_feed_url").text(travis_example_feed_url)
      $('#project_type').val('TeamCityRestProject');
      $('#project_type').change();
      expect($("#project_feed_url").val()).toEqual("");
    });
  });

});
