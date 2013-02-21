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
      $('empty_fields').addClass('hide');
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
            $('.empty_fields').addClass('hide');
            window.clearInterval(trackerInterval);
            trackerIntervalActive = false;
            showTrackerSuccess();
          }
        },
        error: function(result) {
          $('#tracker_status .pending').addClass('hide');
          $('.empty_fields').addClass('hide');
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
    var $buildSetup = $('#build_setup');
    var $disabled_fieldsets = $('fieldset:not(#' + $(this).val() + ')', $container);
    $disabled_fieldsets.addClass('hide');
    $(':input', $disabled_fieldsets).attr('disabled', true);

    var $enabled_fieldset = $('#' + $(this).val());
    $enabled_fieldset.removeClass('hide');
    $(':input', $enabled_fieldset).attr('disabled', false);

    var $branch_name = $('#branch_name');
    var $field_container = $('#field_container');
    if ( $(this).val() == "TravisProject" ) {
      $branch_name.removeClass('hide');
      $field_container.removeClass('hide');
    }
    else {
      $branch_name.addClass('hide');
      $field_container.addClass('hide');
    }

    if ($(this).val() == "TddiumProject") {
       $buildSetup.find('#project_webhooks_enabled_false').click();
       $buildSetup.find('#project_webhooks_enabled_true').prop('disabled', true);
    } else {
      $buildSetup.find('#project_webhooks_enabled_true').prop('disabled', false);
      $buildSetup.find('#project_webhooks_enabled_false').prop('checked', false);
    }

    var $auth_fields = $('.auth_field');
    if ( $(this).val() == "TravisProject" || $(this).val() == "SemaphoreProject") {
      $auth_fields.addClass('hide');
    }
    else {
      $auth_fields.removeClass('hide');
    }
  };

  var isEmpty = function(element) {
    return $(element).val() === "";
  }

  o.validateFeedUrl = function () {
    $('.success, .failure, .unconfigured, .empty_fields', '#polling').addClass('hide');

    if ($('#project_type').val() === "") {
      $('#build_status .unconfigured').removeClass('hide');
      return;
    }

    var $inputs = $('#field_container :input:not(.hide):not(.optional):enabled');
    if(_.some($inputs, isEmpty)){
      if(_.every($inputs, isEmpty)){
        $('#polling .unconfigured').removeClass('hide');
      }else{
        $('#polling .empty_fields').removeClass('hide');
      }
      return;
    }

    $('#polling .pending').removeClass('hide');
    $.ajax({
      url: "/projects/validate_build_info",
      type: "post",
      data: $('form').serialize(),
      success: function (result) {
        if (result.status) {
          $('#polling .pending').addClass('hide');
          $('#build_status .success').removeClass('hide');
        }
        else {
          $('#polling .pending').addClass('hide');
          $('#polling .failure').removeClass('hide').attr("title",result.error_type + ": '" + result.error_text + "'");
        }
      },
      error: function (result) {
        $('#polling .pending').addClass('hide');
        $('#polling .failure').removeClass('hide').attr("title","Server Error");
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
      if($("#project_type").val() != "TravisProject"){
        $('#field_container').addClass('hide');
      }

      $('fieldset#webhooks').removeClass('hide');
      $('fieldset#polling').addClass('hide');
    }
    else if ($('input#project_webhooks_enabled_false:checked').length > 0) {
      $('#field_container').removeClass('hide');
      $('fieldset#webhooks').addClass('hide');
      $('fieldset#polling').removeClass('hide');
    }
  };

  var showPasswordField = function () {
    $('#new_password').removeClass('hide');
    $('#change_password').addClass('hide');
    $('#new_password input').focus();
    $('#password_changed').val('true');
    return false;
  };

  o.init = function () {
    $('#project_tracker_auth_token, #project_tracker_project_id, input[type=submit]')
    .change(handleParameterChange);
    $('#project_type').change(o.handleProjectTypeChange);
    $('#field_container :input').change(o.validateFeedUrl);
    $('input[name="project[webhooks_enabled]"]').change(o.toggleWebhooks);
    $('#field_container input.refresh').click(o.validateFeedUrl);
    $('#change_password a').click(showPasswordField);

    if ($('input[name="project[webhooks_enabled]"]').length > 0) { o.toggleWebhooks(); }

    var $project_online = $('#project_online');
    if ($project_online.length !== 0) {
      if ($project_online.val() === "1") {
        $('#build_status .success').removeClass('hide');
      } else {
        $('#polling .failure').removeClass('hide');
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

