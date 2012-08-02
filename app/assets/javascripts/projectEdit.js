var ProjectEdit = {};
(function (o) {

  var clearTrackerSetupValidations = function (result) {
    $('.success, .failure, .unconfigured', '#tracker_setup').addClass('hide');
  };

  var showAuthTokenError = function () {
    $('#project_tracker_auth_token_status .failure').removeClass('hide');
    $('#tracker_status .failure').removeClass('hide').text("Error in auth token");
  };

  var showProjectIdError = function () {
    $('#project_tracker_project_id_status .failure').removeClass('hide');
    $('#tracker_status .failure').removeClass('hide').text("Error in project ID");
  };

  var showTrackerSuccess = function () {
    $('#project_tracker_project_id_status .success').removeClass('hide');
    $('#project_tracker_auth_token_status .success').removeClass('hide');
    $('#tracker_status .success').removeClass('hide');
  }

  var showGenericError = function () {
    $('#tracker_status .failure').removeClass('hide').text("Error");
  }

  o.validateTrackerSetup = function () {
    var authToken = $('input#project_tracker_auth_token').val();
    var projectId = $('input#project_tracker_project_id').val();

    clearTrackerSetupValidations();

    if (authToken === '' && projectId === '') {
      $('#tracker_status .unconfigured').removeClass('hide');

    } else if (authToken === '') {
      showAuthTokenError();
      return false;

    } else if (projectId === '') {
      showProjectIdError();
      return false;

    } else {
      $('#tracker_status .pending').removeClass('hide');
      $.ajax({
        url: "/projects/validate_tracker_project",
        type: "post",
        data: {
          auth_token: authToken,
          project_id: projectId
        },
        success: function(result) {
          $('#tracker_status .pending').addClass('hide');
          showTrackerSuccess();
        },
        error: function(result) {
          $('#tracker_status .pending').addClass('hide');
          if (result.status == 401) {
            showAuthTokenError();
          } else if (result.status == 404) {
            showProjectIdError();
          } else {
            showGenericError();
          }
        }
      });
    }
  };

  o.handleProjectTypeChange = function () {
    var $container = $('#field_container');

    var $disabled_fieldsets = $('fieldset:not(#' + $(this).val() + ')', $container);
    $disabled_fieldsets.addClass('hide');
    $(':input', $disabled_fieldsets).attr('disabled', true);

    var $enabled_fieldset = $('#' + $(this).val());
    $enabled_fieldset.removeClass('hide');
    $(':input', $enabled_fieldset).attr('disabled', false);
  };

  var showBuildStatusSuccess = function () {
    $('#build_status .success').removeClass('hide');
  }

  o.validateFeedUrl = function () {
    $('.success, .failure, .unconfigured', '#build_status').addClass('hide');

    if ($('#project_type').val() === "") {
      $('#build_status .unconfigured').removeClass('hide');
      return;
    }

    var $inputs = $('#build_setup :input:not(.hide):enabled');
    if ($inputs.is('[value=""]')) {
      if ($inputs.is('[value!=""]')) {
        $('#build_status .failure').removeClass('hide');
      } else {
        $('#build_status .unconfigured').removeClass('hide');
      }
      return;
    }

    $('#build_status .pending').removeClass('hide');
    $.ajax({
      url: "/projects/validate_build_info",
      type: "post",
      data: $('form').serialize(),
      success: function (result) {
        $('#build_status .pending').addClass('hide');
        showBuildStatusSuccess();
      },
      error: function (result) {
        $('#build_status .pending').addClass('hide');
        $('#build_status .failure').removeClass('hide');
      }
    });
  };

  var handleParameterChange = function (event) {
    if (o.validateTrackerSetup() === false) {
      event.stopPropagation();
      event.preventDefault();
    }
  };

  o.init = function () {
    $('#project_tracker_auth_token, #project_tracker_project_id, input[type=submit]')
      .change(handleParameterChange);
    $('#project_type').change(o.handleProjectTypeChange);
    $('#build_setup :input').change(o.validateFeedUrl);

    var $project_online = $('#project_online');
    if ($project_online.length !== 0) {
      if ($project_online.val() === "1") {
        showBuildStatusSuccess();
      } else {
        o.validateFeedUrl();
      }
    }

    var $tracker_online = $('#project_tracker_online');
    if ($tracker_online.length !== 0) {
      if ($tracker_online.val() === "1") {
        showTrackerSuccess();
      } else {
        o.validateTrackerSetup();
      }
    }
  };

})(ProjectEdit);

