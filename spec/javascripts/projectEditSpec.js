describe("project edit", function() {
  beforeEach(function() {
    var fixtures = "<input id='project_tracker_auth_token' type='text' />" +
      "<input id='project_tracker_project_id' type='text' />";
    setFixtures(fixtures);
  });

  describe("when both projectId and authToken are present", function() {
    describe("should validate length of input field", function () {
      describe("when valid", function() {
        beforeEach(function() {
          spyOn($, 'ajax').andCallFake(function (opts) {
            opts.success();
          });
          ProjectEdit.init();
        });

        it("should show the success div", function () {
          $('input#project_tracker_project_id').val("590337").change();
          $('input#project_tracker_auth_token').val("881c7bc3264a00d280225ea409225fe8").change();
          expect($('#project_tracker_auth_token_success')).toExist();
          expect($('#project_tracker_auth_token_error')).not.toExist();
        });
      });

      describe("when not valid", function() {
        describe("when auth token is invalid", function () {
          beforeEach(function() {
            spyOn($, 'ajax').andCallFake(function (opts) {
              opts.error({status: 401});
            });
            ProjectEdit.init();
          });

          it("should show the error div", function () {
            $('input#project_tracker_project_id').val("1111111").change();
            $('input#project_tracker_auth_token').val("2222222").change();
            expect($('#project_tracker_auth_token_success')).not.toExist();
            expect($('#project_tracker_auth_token_error')).toExist();
            expect($('#project_tracker_project_id_error')).not.toExist();
            expect($('#project_tracker_project_id_success')).not.toExist();
          });
        });
        describe("when project id is invalid", function() {
          beforeEach(function() {
            spyOn($, 'ajax').andCallFake(function (opts) {
              opts.error({status: 404});
            });
            ProjectEdit.init();
          });

          it("should show the error div", function () {
            $('input#project_tracker_project_id').val("1111111").change();
            $('input#project_tracker_auth_token').val("2222222").change();
            expect($('#project_tracker_project_id_success')).not.toExist();
            expect($('#project_tracker_project_id_error')).toExist();
            expect($('#project_tracker_auth_token_success')).not.toExist();
            expect($('#project_tracker_auth_token_error')).not.toExist();
          });
        });
      });
    });
  });
  describe("when one or the other is not present", function (argument) {
    beforeEach(function() {
      spyOn($, 'ajax').andCallFake(function (opts) {
        opts.error();
      });
      ProjectEdit.init();
    });
    describe("when the authToken is not present", function() {
      it("should not validate", function() {
        $('input#project_tracker_project_id').val("1111111").change();
        expect($('#project_tracker_auth_token_success')).not.toExist();
        expect($('#project_tracker_auth_token_error')).not.toExist();
      });
    });

    describe("when the projectId is not present", function() {
      it("should not validate", function() {
        $('input#project_tracker_auth_token').val("2222222").change();
        expect($('#project_tracker_auth_token_success')).not.toExist();
        expect($('#project_tracker_auth_token_error')).not.toExist();
      });
    });
  });

  describe("project feed url", function() {
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
      ProjectEdit.init();
    });

    describe('when selecting a Travis project', function() {
      it('adds an example url to the feed URL text area', function() {
        $('#project_type').val('TravisProject');
        $('#project_type').change();
        expect($("#project_feed_url").val()).toEqual(travis_example_feed_url);
      });

      it('does not overwrite exisiting data in the feed url text area', function() {
        $("#project_feed_url").text('Some Other URL');
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
        $("#project_feed_url").text('Some Other URL');
        $('#project_type').val('TeamCityRestProject');
        $('#project_type').change();
        expect($("#project_feed_url").val()).toEqual("Some Other URL");
      });

      it('removes the travis example URL', function(){
        $("#project_feed_url").text(travis_example_feed_url);
        $('#project_type').val('TeamCityRestProject');
        $('#project_type').change();
        expect($("#project_feed_url").val()).toEqual("");
      });
    });
  });
});
