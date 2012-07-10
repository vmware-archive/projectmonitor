var ProjectEdit = {};
(function (o) {
  var clearTrackerSetupValidations = function (result) {
    $('div#project_tracker_auth_token_success').remove();
    $('div#project_tracker_project_id_success').remove();
    $('div#project_tracker_auth_token_error').remove();
    $('div#project_tracker_project_id_error').remove();
  };

  var showAuthTokenError = function (e) {
    $('<div id="project_tracker_auth_token_error">X</div>').insertAfter("input#project_tracker_auth_token");
  };

  var showProjectIdError = function (e) {
    $('<div id="project_tracker_project_id_error">X</div>').insertAfter("input#project_tracker_project_id");
  };

  o.validateTrackerSetup = function (e) {
    var authToken = $('input#project_tracker_auth_token').val();
    var projectId = $('input#project_tracker_project_id').val();

    clearTrackerSetupValidations();

    if (authToken === '' || projectId === '') {
      e.stopPropagation();
      e.preventDefault();

      if (authToken === '') { showAuthTokenError(e); }
      if (projectId === '') { showProjectIdError(e); }
    } else {
      $.ajax({
        url: "/projects/validate_tracker_project",
        type: "post",
        data: {
          auth_token: authToken,
          project_id: projectId
        },
        success: function(result) {
          $('<div id="project_tracker_auth_token_success">OK</div>').insertAfter("input#project_tracker_auth_token");
          $('<div id="project_tracker_project_id_success">OK</div>').insertAfter("input#project_tracker_project_id");
        },
        error: function(result) {
          if (result.status == 401) {
            showAuthTokenError();
          } else if (result.status == 404) {
            showProjectIdError();
          }
        }
      });
    }
  };

  o.validateFeedUrl = function () {
    var travis_example_feed_url = "http://travis-ci.org/[account]/[project]/cc.xml";
    var field_url = $("#project_feed_url");

    if($(this).val() == 'TravisProject' && field_url.val() === '') {
      field_url.val(travis_example_feed_url);
    } else if($(this).val() != 'TravisProject' && field_url.val() === travis_example_feed_url) {
      field_url.val("");
    }
  };

  o.init = function () {
    $('#project_tracker_auth_token').change(o.validateTrackerSetup);
    $('#project_tracker_project_id').change(o.validateTrackerSetup);
    $('input[type=submit]').click(o.validateTrackerSetup);
    $('#project_type').change(o.validateFeedUrl);
  };

})(ProjectEdit);

