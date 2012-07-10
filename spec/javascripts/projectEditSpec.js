describe("project edit", function() {
  describe("validations on pivotal tracker setup", function() {
    beforeEach(function() {
      var fixtures = "<input id='project_tracker_auth_token' type='text' />" +
        "<input id='project_tracker_project_id' type='text' />" +
        "<input type='submit'/ >";
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

    describe("when the authToken is not present", function() {
      beforeEach(function() {
        spyOn($, 'ajax').andCallFake(function (opts) {
          opts.error({status: 401});
        });
        ProjectEdit.init();
      });

      it("should show the auth token error", function() {
        $('input#project_tracker_project_id').val("1111111").change();
        expect($('#project_tracker_auth_token_success')).not.toExist();
        expect($('#project_tracker_project_id_success')).not.toExist();
        expect($('#project_tracker_project_id_error')).not.toExist();
        expect($('#project_tracker_auth_token_error')).toExist();
      });
    });

    describe("when the projectId is not present", function() {
      beforeEach(function() {
        spyOn($, 'ajax').andCallFake(function (opts) {
          opts.error({status: 404});
        });
        ProjectEdit.init();
      });

      it("should show the project id error", function() {
        $('input#project_tracker_auth_token').val("2222222").change();
        expect($('#project_tracker_auth_token_success')).not.toExist();
        expect($('#project_tracker_auth_token_error')).not.toExist();
        expect($('#project_tracker_project_id_success')).not.toExist();
        expect($('#project_tracker_project_id_error')).toExist();
      });
    });

    describe("when clicking submit", function() {
      describe("when the auth token and project id are present", function() {
        beforeEach(function() {
          $('input#project_tracker_project_id').val("590337");
          $('input#project_tracker_auth_token').val("881c7bc3264a00d280225ea409225fe8");
          ProjectEdit.init();
          $('input[type=submit]').click();
        });

        it("should not show any error messages", function() {
          expect($('#project_tracker_auth_token_error')).not.toExist();
          expect($('#project_tracker_project_id_error')).not.toExist();
        });
      });

      describe("when the auth token is not present", function() {
        beforeEach(function() {
          $('input#project_tracker_project_id').val("590337");
          $('input#project_tracker_auth_token').val("");
          ProjectEdit.init();
          $('input[type=submit]').click();
        });

        it("should show the auth token error", function() {
          expect($('#project_tracker_auth_token_error')).toExist();
        });
      });

      describe("when the project id is not present", function() {
        beforeEach(function() {
          $('input#project_tracker_project_id').val("");
          $('input#project_tracker_auth_token').val("881c7bc3264a00d280225ea409225fe8");
          ProjectEdit.init();
          $('input[type=submit]').click();
        });

        it("should show the project id error", function() {
          expect($('#project_tracker_project_id_error')).toExist();
        });
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
