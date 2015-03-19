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
    var val = $(this).val();

    var $disabled_fieldsets = $('.project-attributes', $('#field_container'));
    $disabled_fieldsets.addClass('hide');
    $(':input', $disabled_fieldsets).attr('disabled', true);

    var $enabled_fieldset = $('#' + val);
    $enabled_fieldset.removeClass('hide');
    $(':input', $enabled_fieldset).attr('disabled', false);

    var use_feed = _.contains(["TravisProject", "TravisProProject", "SemaphoreProject", "CircleCiProject"], val);
    $('#branch_name').toggleClass('hide', !use_feed);
    $('#field_container').toggleClass('hide', !use_feed);

    var $buildSetup = $('#build_setup');
    var $webhooks_enabled = $buildSetup.find('#project_webhooks_enabled_true');
    var $webhooks_disabled = $buildSetup.find('#project_webhooks_enabled_false');

    $webhooks_enabled.prop('disabled', val == "TddiumProject");
    $webhooks_enabled.prop('checked', false);
    $webhooks_disabled.prop('checked', false);

    if (val == "TddiumProject") {
      $webhooks_disabled.prop('checked', true);
    }

    if (val == "CodeshipProject") {
      $('#field_container').removeClass('hide');
      $('#branch_name').removeClass('hide');
    }

    $('.auth_field').toggleClass('hide', use_feed);

    o.toggleWebhooks();
  };

  o.setProviderSpecificVisibility = function () {
    $('.provider-specific').addClass('hide');
    if (val = $('select#project_type').val()) {
      $('.provider-specific.' + val).removeClass('hide');
    }
  }

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
      type: "patch",
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
      var val = $("#project_type").val();
      if(val != "TravisProject" && val != "TravisProProject" && val != "CodeshipProject"){
        $('#field_container').addClass('hide');
      }

      $('#webhook_url').removeClass('hide');
      $('fieldset#polling').addClass('hide');
    }
    else if ($('input#project_webhooks_enabled_false:checked').length > 0) {
      $('#field_container').removeClass('hide');
      $('#webhook_url').addClass('hide');
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
    $('#project_type').change(o.handleProjectTypeChange).change(o.validateFeedUrl).change(o.setProviderSpecificVisibility);
    $('#field_container :input').change(o.validateFeedUrl);
    $('input[name="project[webhooks_enabled]"]').change(o.toggleWebhooks);
    $('#build_setup input.refresh').click(o.validateFeedUrl);
    $('#change_password a').click(showPasswordField);

    $(document).ready(o.setProviderSpecificVisibility); // To handle redirect back to page after following link

    if ($('input[name="project[webhooks_enabled]"]').length > 0) { o.toggleWebhooks(); }

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
