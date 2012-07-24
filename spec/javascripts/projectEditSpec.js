describe("project edit", function() {
  describe("validations on pivotal tracker setup", function() {
    beforeEach(function() {
      var fixtures = "<input id='project_tracker_auth_token' type='text' />" +
        "<input id='project_tracker_project_id' type='text' />" +
        "<input type='submit'/ >";
      setFixtures(fixtures);
    });

    describe("when both projectId and authToken are missing", function() {
      beforeEach(function() {
        ProjectEdit.init();
      });

      it("should not validate anything", function() {
        $('input#project_tracker_project_id').val("").change();
        $('input#project_tracker_auth_token').val("").change();
        expect($('#project_tracker_project_id_error')).not.toExist();
        expect($('#project_tracker_auth_token_error')).not.toExist();
      });
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
      describe("when neither the auth token nor project id are present", function() {
        beforeEach(function() {
          $('input#project_tracker_project_id').val("");
          $('input#project_tracker_auth_token').val("");
          ProjectEdit.init();
          $('input[type=submit]').click();
        });

        it("should not show any error messages", function() {
          expect($('#project_tracker_auth_token_error')).not.toExist();
          expect($('#project_tracker_project_id_error')).not.toExist();
        });
      });

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

  describe("Feed URL fields", function() {
    beforeEach(function() {
      setFixtures('' +
        '<select id="project_type" name="project[type]"><option value=""></option>' +
        '  <option value="CruiseControlProject">Cruise Control Project</option>' +
        '  <option value="JenkinsProject">Jenkins Project</option>' +
        '</select>' +
        '<div id="field_container">' +
        '  <fieldset id="CruiseControlProject">' +
        '    <p>' +
        '      <label for="project_cruise_control_rss_feed_url">Rss Feed Url</label>' +
        '      <input id="project_cruise_control_rss_feed_url" name="project[cruise_control_rss_feed_url]"/>' +
        '    </p>' +
        '  </fieldset>' +
        '  <fieldset class="hide" id="JenkinsProject">' +
        '    <p>' +
        '      <label for="project_jenkins_base_url">Base URL</label>' +
        '      <input id="project_jenkins_base_url" name="project[jenkins_base_url]"/>' +
        '    </p>' +
        '  </fieldset>' +
        '</div>');
      ProjectEdit.init();
      $('#project_type').val('JenkinsProject');
      $('#project_type').change();
    });

    it("makes the Jenkins project fieldset visible", function() {
      expect($('fieldset#JenkinsProject')).toExist();
      expect($('fieldset#JenkinsProject').hasClass('hide')).toBeFalsy();
      expect($('#project_jenkins_base_url').attr('disabled')).toBeFalsy();
    });

    it("makes the Cruise Control project fieldset invisible", function() {
      expect($('fieldset#CruiseControlProject').hasClass('hide')).toBeTruthy();
      expect($('#project_cruise_control_rss_feed_url').attr('disabled')).toBeTruthy();
    });
  });
});
