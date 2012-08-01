var ProjectEdit = {};
(function (o) {

  var clearTrackerSetupValidations = function (result) {
    $('#tracker_setup span span').addClass('hide');
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
          }
        }
      });
    }
  };

  o.validateFeedUrl = function () {
    var container = $('#field_container');

    var $disabled_fieldsets = $('fieldset:not(#' + $(this).val() + ')', container);
    $disabled_fieldsets.addClass('hide');
    $(':input', $disabled_fieldsets).attr('disabled', true);

    var $enabled_fieldset = $('#' + $(this).val());
    $enabled_fieldset.removeClass('hide');
    $(':input', $enabled_fieldset).attr('disabled', false);
  };

  var handleParameterChange = function (event) {
    if (o.validateTrackerSetup() === false) {
      event.stopPropagation();
      event.preventDefault();
    }
  };

  o.init = function () {
    $('#project_tracker_auth_token').change(handleParameterChange);
    $('#project_tracker_project_id').change(handleParameterChange);
    $('input[type=submit]').click(handleParameterChange);
    $('#project_type').change(o.validateFeedUrl);

    if ($('#project_tracker_online').val() === "1") {
      showTrackerSuccess();
    } else {
      o.validateTrackerSetup();
    }
  };

})(ProjectEdit);

