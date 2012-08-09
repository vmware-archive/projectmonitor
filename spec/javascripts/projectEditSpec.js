describe("project edit", function() {
  describe("validations on pivotal tracker setup", function() {
    beforeEach(function() {
      var fixtures = "<fieldset id='tracker_setup'><input id='project_tracker_online'/>" +
        "<input id='project_tracker_auth_token' type='text'/>" +
        "<span id='project_tracker_auth_token_status'>" +
        "<span class='success hide'/><span class='failure hide' /></span>" +
        "<input id='project_tracker_project_id' type='text'/>" +
        "<span id='project_tracker_project_id_status'>" +
        "<span class='success hide'/><span class='failure hide' /></span>" +
        "<span id='tracker_status'>" +
        "<span class='success hide'/><span class='pending hide' />" +
        "<span class='failure hide'/><span class='unconfigured hide' />" +
        "</span>" +
        "<input type='submit'/ ></fieldset>";
      setFixtures(fixtures);
    });

    describe("when the project is online", function () {
      beforeEach(function() {
        $('#project_tracker_online').val("1");
        ProjectEdit.init();
      });

      it("should not validate anything and show success", function() {
        expect($('.success')).not.toHaveClass('hide');
        expect($('.pending, .failure, .unconfigured')).toHaveClass('hide');
      });
    });

    describe("when both projectId and authToken are missing", function() {
      beforeEach(function() {
        ProjectEdit.init();
      });

      it("should not validate anything", function() {
        expect($('#tracker_status .unconfigured')).not.toHaveClass('hide');
        expect($('.success, .failure, .pending')).toHaveClass('hide');
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
            expect($(' .success')).not.toHaveClass('hide');
            expect($('.success, .failure, .pending')).toHaveClass('hide');
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
              expect($('.success, .pending, .unconfigured')).toHaveClass('hide');
              expect($('#project_tracker_project_id_status .failure')).toHaveClass('hide');
              expect($('#project_tracker_auth_token_status .failure')).not.toHaveClass('hide');
              expect($('#tracker_status .failure')).not.toHaveClass('hide');
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
              expect($('.success, .pending, .unconfigured')).toHaveClass('hide');
              expect($('#project_tracker_project_id_status .failure')).not.toHaveClass('hide');
              expect($('#project_tracker_auth_token_status .failure')).toHaveClass('hide');
              expect($('#tracker_status .failure')).not.toHaveClass('hide');
            });
          });

          describe("when some other kind of error occurs", function() {
            beforeEach(function() {
              spyOn($, 'ajax').andCallFake(function (opts) {
                opts.error({status: 500});
              });
              ProjectEdit.init();
            });

            it("should show the error div", function () {
              $('input#project_tracker_project_id').val("1111111").change();
              $('input#project_tracker_auth_token').val("2222222").change();
              expect($('.success, .pending, .unconfigured')).toHaveClass('hide');
              expect($('#project_tracker_project_id_status .failure')).toHaveClass('hide');
              expect($('#project_tracker_auth_token_status .failure')).toHaveClass('hide');
              expect($('#tracker_status .failure')).not.toHaveClass('hide');
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
        expect($('#project_tracker_project_id_status .failure')).toHaveClass('hide');
        expect($('#project_tracker_auth_token_status .failure')).not.toHaveClass('hide');
        expect($('.success, .pending, .unconfigured')).toHaveClass('hide');
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
        expect($('.success, .pending, .unconfigured')).toHaveClass('hide');
        expect($('#project_tracker_project_id_status .failure')).not.toHaveClass('hide');
        expect($('#project_tracker_auth_token_status .failure')).toHaveClass('hide');
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
          expect($('.failure')).toHaveClass('hide');
          expect($('#tracker_status .unconfigured')).not.toHaveClass('hide');
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
          expect($('.failure')).toHaveClass('hide');
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
          expect($('#project_tracker_auth_token_status .failure')).not.toHaveClass('hide');
          expect($('#tracker_status .failure')).not.toHaveClass('hide');
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
          expect($('#project_tracker_project_id_status .failure')).not.toHaveClass('hide');
          expect($('#tracker_status .failure')).not.toHaveClass('hide');
        });
      });
    });
  });

  describe("Feed URL fields", function() {
    beforeEach(function() {
      setFixtures(
        '<select id="project_type" name="project[type]">' +
        '  <option value=""></option>' +
        '  <option value="CruiseControlProject">Cruise Control Project</option>' +
        '  <option value="JenkinsProject">Jenkins Project</option>' +
        '</select>' +
        '<div id="polling">' +
        '  <div id="field_container">' +
        '    <fieldset id="CruiseControlProject">' +
        '      <input id="project_cruise_control_rss_feed_url" name="project[cruise_control_rss_feed_url]"/>' +
        '    </fieldset>' +
        '    <fieldset class="hide" id="JenkinsProject">' +
        '      <input id="project_jenkins_base_url" name="project[jenkins_base_url]"/>' +
        '      <input id="project_jenkins_build_name" name="project[jenkins_build_name]" size="30" type="text">' +
        '    </fieldset>' +
        '    <input id="project_auth_username" name="project[auth_username]" size="40" type="text">' +
        '  </div>' +
        '  <input id="project_online" name="project[online]" type="hidden"/>' +
        '  <div id="build_status">' +
        '    <span class="hide"/>' +
        '    <span class="unconfigured hide"/>' +
        '    <span class="failure hide"/>' +
        '    <span class="success hide"/>' +
        '  </div>' +
        '</div>');
    });

    describe("changing available inputs", function () {
      beforeEach(function() {
        ProjectEdit.init();
        $('#project_type').val('JenkinsProject').change();
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

    describe("when the project is already marked as online", function() {
      beforeEach(function() {
        $('#project_online').val("1");
        ProjectEdit.init();
      });

      it("should display the success message", function() {
        expect($("#build_status .success")).not.toHaveClass("hide");
      });
    })

    describe("when all the build configuration inputs are present", function() {
      describe("and they are valid", function() {
        beforeEach(function() {
          spyOn($, 'ajax').andCallFake(function (opts) {
            opts.success();
          });
          ProjectEdit.init();
          $('#project_type').val('JenkinsProject').change();
          $('#project_jenkins_base_url').val("foobar").change();
          $('#project_jenkins_build_name').val("grok").change();
          $('#project_cruise_control_rss_feed_url').val("foobar").change();
          $('#project_auth_username').val('alice').change();
        });

        it("should display the success message", function() {
          expect($("#build_status .success")).not.toHaveClass("hide");
        });
      });

      describe("and they are invalid", function() {
        beforeEach(function() {
          spyOn($, 'ajax').andCallFake(function (opts) {
            opts.error({status: 404});
          });
          ProjectEdit.init();
          $('#project_type').val('JenkinsProject').change();
          $('#project_jenkins_base_url').val("foobar").change();
          $('#project_jenkins_build_name').val("grok").change();
        });

        it("should display the failure message", function() {
          expect($("#build_status .failure")).not.toHaveClass("hide");
        });
      });
    });

    describe("when some of the build configuration inputs are blank", function() {
      beforeEach(function() {
        ProjectEdit.init();
        $('#project_type').val('JenkinsProject').change();
        $('#project_jenkins_base_url').val("").change();
        $('#project_jenkins_build_name').val("foobar").change();
      });

      it("should display the failure message", function() {
        expect($("#build_status .failure")).not.toHaveClass("hide");
      });
    });

    describe("when the project type is blank but an input is filled in", function() {
      beforeEach(function() {
        ProjectEdit.init();
        $('#project_auth_username').val('alice').change();
      });

      it("should display the unconfigured message", function() {
        expect($("#build_status .unconfigured")).not.toHaveClass("hide");
      });
    });

    describe("when all of the build configuration inputs are blank", function() {
      beforeEach(function() {
        ProjectEdit.init();
        $('#project_type').val('JenkinsProject').change();
        $('#project_jenkins_base_url').val("").change();
      });

      it("should display the unconfigured message", function() {
        expect($("#build_status .unconfigured")).not.toHaveClass("hide");
      });
    });
  });
  describe("toggling payload strategy", function() {
    beforeEach(function() {
      setFixtures('<input checked="checked" id="project_webhooks_enabled_true" name="project[webhooks_enabled]" type="radio" value="true">' +
                  '<input id="project_webhooks_enabled_false" name="project[webhooks_enabled]" type="radio" value="false">' +
                  '<fieldset id="webhooks" /><fieldset id="polling" />')
      ProjectEdit.init();
    });
    it("should toggle webhooks and polling when checked", function() {
      expect($('#webhooks')).not.toHaveClass('hide');
      expect($('#polling')).toHaveClass('hide');
      $('input#project_webhooks_enabled_false').val('checked', 'checked').change();
      $('input#project_webhooks_enabled_true').val('checked', '').change();
      expect($('#webhooks')).not.toHaveClass('hide');
      expect($('#polling')).toHaveClass('hide');
      $('input#project_webhooks_enabled_false').val('checked', '').change();
      $('input#project_webhooks_enabled_true').val('checked', 'checked').change();
      expect($('#webhooks')).not.toHaveClass('hide');
      expect($('#polling')).toHaveClass('hide');
    });
  });
});
