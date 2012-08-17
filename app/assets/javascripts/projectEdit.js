var ProjectEdit = {};
(function (o) {
  var trackerInterval;
  var trackerIntervalActive = false;
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
          id: document.location.pathname.split("/")[2],
          auth_token: authToken,
          project_id: projectId
        },
        success: function(data, status, result) {
          if (result.status == 202) {
            if (trackerIntervalActive === false) {
              trackerInterval = window.setInterval(o.validateTrackerSetup, 1000);
              trackerIntervalActive = true;
            }
          }
          else if (result.status == 200) {
            $('#tracker_status .pending').addClass('hide');
            window.clearInterval(trackerInterval);
            trackerIntervalActive = false;
            showTrackerSuccess();
          }
        },
        error: function(result) {
          $('#tracker_status .pending').addClass('hide');
          window.clearInterval(trackerInterval);
          trackerIntervalActive = false;
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
    $('.success, .failure, .unconfigured', '#polling').addClass('hide');

    if ($('#project_type').val() === "") {
      $('#build_status .unconfigured').removeClass('hide');
      return;
    }

    var $inputs = $('#polling :input:not(.hide):not(.optional):enabled');
    if ($inputs.is('[value=""]')) {
      if ($inputs.is('[value!=""]')) {
        // TODO: This should probably show something like 'Some fields are
        // missing' rather than an error
        $('#polling .failure').removeClass('hide');
      } else {
        $('#polling .unconfigured').removeClass('hide');
      }
      return;
    }

    $('#polling .pending').removeClass('hide');
    $.ajax({
      url: "/projects/validate_build_info",
      type: "post",
      data: $('form').serialize(),
      success: function (result) {
        $('#polling .pending').addClass('hide');
        showBuildStatusSuccess();
      },
      error: function (result) {
        $('#polling .pending').addClass('hide');
        $('#polling .failure').removeClass('hide');
      }
    });
  };

  var handleParameterChange = function (event) {
    if (o.validateTrackerSetup() === false) {
      event.stopPropagation();
      event.preventDefault();
    }
  };

  o.toggleWebhooks = function () {
    if ($('input#project_webhooks_enabled_true:checked').length > 0) {
      $('fieldset#webhooks').removeClass('hide');
      $('fieldset#polling').addClass('hide');
    }
    else if ($('input#project_webhooks_enabled_false:checked').length > 0) {
      $('fieldset#webhooks').addClass('hide');
      $('fieldset#polling').removeClass('hide');
    }
  };

  o.init = function () {
    $('#project_tracker_auth_token, #project_tracker_project_id, input[type=submit]')
    .change(handleParameterChange);
    $('#project_type').change(o.handleProjectTypeChange);
    $('#polling :input').change(o.validateFeedUrl);
    $('input[name="project[webhooks_enabled]"]').change(o.toggleWebhooks);

    if ($('input[name="project[webhooks_enabled]"]').length > 0) { o.toggleWebhooks(); }

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

