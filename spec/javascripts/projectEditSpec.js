describe("project edit", function() {
  beforeEach(function() {
    jasmine.Ajax.install();
  });

  afterEach(function() {
    jasmine.Ajax.uninstall();
  });

  it('does not invoke validateFeedUrl on initialization', function() {
    spyOn(ProjectEdit, 'validateFeedUrl');
    ProjectEdit.init();
    expect(ProjectEdit.validateFeedUrl).not.toHaveBeenCalled();
  });

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
            spyOn($, 'ajax').and.callFake(function (opts) {
              opts.success({},"",{status: 200});
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
              spyOn($, 'ajax').and.callFake(function (opts) {
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
              spyOn($, 'ajax').and.callFake(function (opts) {
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
              spyOn($, 'ajax').and.callFake(function (opts) {
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
        spyOn($, 'ajax').and.callFake(function (opts) {
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
        spyOn($, 'ajax').and.callFake(function (opts) {
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
        '  <option value="TravisProject">TravisProject</option>' +
        '  <option value="SemaphoreProject">SemaphoreProject</option>' +
        '  <option value="TddiumProject">TddiumProject</option>' +
        '</select>' +
        '<div id="field_container" class="hide">' +
        '  <div class="project-attributes" id="CruiseControlProject">' +
        '    <input id="project_cruise_control_rss_feed_url" name="project[cruise_control_rss_feed_url]"/>' +
        '  </div>' +
        '  <div class="project-attributes hide" id="JenkinsProject">' +
        '    <input id="project_jenkins_base_url" name="project[jenkins_base_url]"/>' +
        '    <input id="project_jenkins_build_name" name="project[jenkins_build_name]" type="text">' +
        '  </div>' +
        '  <div class="project-attributes hide" id="TddiumProject">' +
        '    <input id="project_ci_auth_token" name="project[ci_auth_token]" size="30" type="text">' +
        '    <input id="project_tddium_project_name" name="project[tddium_project_name]" placeholder="repo_name (branch_name)" size="30" type="text">' +
        '  </div>' +
        '  <input id="project_auth_username" name="project[auth_username]" type="text">' +
        '  <input id="project_auth_password" name="project[auth_password]" type="text" class="optional">' +
        '</div>' +
        '<fieldset id="polling">' +
        '  <input id="project_online" name="project[online]" type="hidden"/>' +
        '  <div id="build_status">' +
        '    <span class="hide"/>' +
        '    <span class="unconfigured hide"/>' +
        '    <span class="failure hide"/>' +
        '    <span class="success hide"/>' +
        '  </div>' +
        '</fieldset>' +
        '<fieldset id="build_setup">' +
        '  <input type="radio" id="project_webhooks_enabled_true"/>' +
        '  <input type="radio" id="project_webhooks_enabled_false"/>' +
        '  <p class="hide" id="branch_name">' +
        '    <label for="project_build_branch">Branch Name</label>' +
        '    <input id="project_build_branch" name="project[build_branch]" size="30" type="text" class="">' +
        '  </p>' +
        '</fieldset>');
    });

    describe("changing available inputs", function () {
      beforeEach(function() {
        ProjectEdit.init();
        $('#project_type').val('JenkinsProject').change();
      });

      it("makes the Jenkins project div visible", function() {
        expect($('.project-attributes#JenkinsProject')).toExist();
        expect($('.project-attributes#JenkinsProject').hasClass('hide')).toBeFalsy();
        expect($('#project_jenkins_base_url').attr('disabled')).toBeFalsy();
      });

      it("makes the Cruise Control project div invisible", function() {
        expect($('.project-attributes#CruiseControlProject').hasClass('hide')).toBeTruthy();
        expect($('#project_cruise_control_rss_feed_url').attr('disabled')).toBeTruthy();
      });
    });

    describe("showing the branch field", function() {
      beforeEach(function() {
        ProjectEdit.init();
      });

      it("shows the branch field when a Travis Project is selected", function() {
        $('#project_type').val('TravisProject').change();
        expect($('#branch_name')).toExist();
        expect($('#branch_name').hasClass('hide')).toBeFalsy();
      });

      it("shows the branch field when a Semaphore Project is selected", function() {
        $('#project_type').val('SemaphoreProject').change();
        expect($('#branch_name')).toExist();
        expect($('#branch_name').hasClass('hide')).toBeFalsy();
      });

      it("shows the field_container when a Travis Project is selected", function() {
        $('#project_type').val('TravisProject').change();
        expect($('#field_container')).toExist();
        expect($('#field_container').hasClass('hide')).toBeFalsy();
      });

      it("hides the branch field when another project type is selected", function() {
        $('#project_type').val('JenkinsProject').change();
        expect($('#branch_name').hasClass('hide')).toBeTruthy();
      });

      it("hides the field_container when another project type is selected", function() {
        $('#project_type').val('JenkinsProject').change();
        expect($('#field_container').hasClass('hide')).toBeTruthy();
      });
    });

    describe("disable webhook and default to polling on projects that do not support webhooks", function() {
      beforeEach(function() {
        ProjectEdit.init();
        $('#project_type').val('TddiumProject').change();
      });

      it("Tddium projects", function() {
        expect($('#project_webhooks_enabled_true').attr('disabled')).toBeTruthy();
        expect($('#project_webhooks_enabled_false').prop('checked')).toBeTruthy();
      });
    });

    describe("when changing from webhooks to polling", function() {
      beforeEach(function() {
        ProjectEdit.init();
        $('#project_type').val('JenkinsProject').change();
        $('#project_webhooks_enabled_true').click();
        $('#project_type').val('TddiumProject').change();
      });
      it("should display the Tddium fieldset", function() {
        expect($('fieldset#TddiumProject').hasClass('hide')).toBeFalsy();
        expect($('fieldset#polling').hasClass('hide')).toBeFalsy();
      });
    });

    describe("when all the build configuration inputs are present", function() {
      describe("and the tracker returns a parseable build status", function() {
        beforeEach(function() {
          spyOn($, 'ajax').and.callFake(function (opts) {
            opts.success({status: true});
          });
          ProjectEdit.init();
          $('#project_type').val('JenkinsProject').change();
          $('#project_jenkins_base_url').val("foobar").change();
          $('#project_jenkins_build_name').val("grok").change();
          $('#project_auth_username').val('alice').change();
        });

        it("should display the success message", function() {
          expect($("#build_status .success")).not.toHaveClass("hide");
        });
      });

      describe("and the tracker does not return a parseable build status", function() {
        beforeEach(function() {
          spyOn($, 'ajax').and.callFake(function (opts) {
            opts.success({status: false, error_type: "Error Type", error_text: "Error Text"});
          });
          ProjectEdit.init();
          $('#project_type').val('JenkinsProject').change();
          $('#project_jenkins_base_url').val("foobar").change();
          $('#project_jenkins_build_name').val("grok").change();
          $('#project_cruise_control_rss_feed_url').val("foobar").change();
          $('#project_auth_username').val('alice').change();
        });

        it("should display the server's error message", function() {
          expect($("#build_status .failure")).not.toHaveClass("hide");
          expect($("#build_status .failure").attr('title')).toBe("Error Type: 'Error Text'");
        });
      });

      describe("and the server does not respond correctly", function() {
        beforeEach(function() {
          spyOn($, 'ajax').and.callFake(function (opts) {
            opts.error({status: 404});
          });
          ProjectEdit.init();
          $('#project_type').val('JenkinsProject').change();
          $('#project_jenkins_base_url').val("foobar").change();
          $('#project_jenkins_build_name').val("grok").change();
          $('#project_auth_username').val('user').change();
        });

        it("should display the failure message", function() {
          expect($("#build_status .failure")).not.toHaveClass("hide");
        });
        it("should add a tooltip indicating a server error", function() {
          expect($('#build_status .failure').attr('title')).toBe('Server Error');
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

      it("should display the Some Fields Empty message", function() {
        expect($("#build_status .empty_fields")).not.toHaveClass("hide");
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


    describe("when not a travis build", function(){
      beforeEach(function() {
        setFixtures('<div id="project_type"></div>' +
                    '<div id="field_container"></div>' +
                    '<input checked="checked" id="project_webhooks_enabled_true" name="project[webhooks_enabled]" type="radio" value="true">' +
                    '<input id="project_webhooks_enabled_false" name="project[webhooks_enabled]" type="radio" value="false">' +
                    '<fieldset id="webhook_url" /><fieldset id="polling" />')
        ProjectEdit.init();
      });

      it("should toggle webhooks and polling when checked", function() {
        expect($('#webhook_url')).not.toHaveClass('hide');
        expect($('#polling')).toHaveClass('hide');
        expect($('#field_container')).toHaveClass('hide');

        $('input#project_webhooks_enabled_false').prop('checked', true);
        $('input#project_webhooks_enabled_true').removeAttr('checked').change();
        expect($('#webhook_url')).toHaveClass('hide');
        expect($('#polling')).not.toHaveClass('hide');
        expect($('#field_container')).not.toHaveClass('hide');

        $('input#project_webhooks_enabled_false').removeAttr('checked');
        $('input#project_webhooks_enabled_true').prop('checked', true).change();
        expect($('#webhook_url')).not.toHaveClass('hide');
        expect($('#polling')).toHaveClass('hide');
        expect($('#field_container')).toHaveClass('hide');
      });
    })

    describe("when a travis build", function(){
      beforeEach(function() {
        setFixtures('<div id="project_type"></div>' +
                    '<div id="field_container"></div>' +
                    '<input checked="checked" id="project_webhooks_enabled_true" name="project[webhooks_enabled]" type="radio" value="true">' +
                    '<input id="project_webhooks_enabled_false" name="project[webhooks_enabled]" type="radio" value="false">' +
                    '<fieldset id="webhook_url" /><fieldset id="polling" />')
        $('#project_type').val("TravisProject")
        ProjectEdit.init();
      });

      it("should toggle webhooks and polling when checked", function() {
        expect($('#webhook_url')).not.toHaveClass('hide');
        expect($('#polling')).toHaveClass('hide');
        expect($('#field_container')).not.toHaveClass('hide');

        $('input#project_webhooks_enabled_false').prop('checked', true);
        $('input#project_webhooks_enabled_true').removeAttr('checked').change();
        expect($('#webhook_url')).toHaveClass('hide');
        expect($('#polling')).not.toHaveClass('hide');
        expect($('#field_container')).not.toHaveClass('hide');

        $('input#project_webhooks_enabled_false').removeAttr('checked');
        $('input#project_webhooks_enabled_true').prop('checked', true).change();
        expect($('#webhook_url')).not.toHaveClass('hide');
        expect($('#polling')).toHaveClass('hide');
        expect($('#field_container')).not.toHaveClass('hide');
      });
    })
  });
});
