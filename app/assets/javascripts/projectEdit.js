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
    o.setProjectTypeVisibility(val);
    var $buildSetup = $('#build_setup');


    var $webhooks_enabled = $buildSetup.find('#project_webhooks_enabled_true');
    var $webhooks_disabled = $buildSetup.find('#project_webhooks_enabled_false');

    $webhooks_enabled.prop('disabled', val == "TddiumProject");

    $webhooks_enabled.prop('checked', false);
    $webhooks_disabled.prop('checked', false);

    if (val == "TddiumProject") {
      $webhooks_disabled.prop('checked', true);
    }
    o.toggleWebhooks();
  }

  o.setProjectTypeVisibility = function (val) {
    var $disabled_fieldsets = $('.project-attributes', $('#field_container'));
    $disabled_fieldsets.addClass('hide');
    $(':input', $disabled_fieldsets).attr('disabled', true);

    var $enabled_fieldset = $('#' + val);
    $enabled_fieldset.removeClass('hide');
    $(':input', $enabled_fieldset).attr('disabled', false);

    var use_feed = !(_.contains(["TravisProject", "TravisProProject", "SemaphoreProject", "CircleCiProject"], val));
    $('#branch_name').toggleClass('hide', use_feed);
    $('#field_container').toggleClass('hide', use_feed);

    if (val == "CodeshipProject") {
      $('#field_container').removeClass('hide');
      $('#branch_name').removeClass('hide');
    }

    $('.auth_field').toggleClass('hide', !use_feed);

  }

  o.setProviderSpecificVisibility = function () {
    $('.provider-specific').addClass('hide');
    if (val = $('select#project_type').val()) {
      $('.provider-specific.' + val).removeClass('hide');
    }
  }

  var isEmpty = function(element) {
    return $(element).val() === "";
  }

  var humanReadableErrorHTML = function(error) {
    var string = "";
    var error_text = error.error_text;
    var project_type = $("#project_type").val();
    var url = "";
    if (project_type === "JenkinsProject" || project_type === "CruiseControlProject") {
      if (error_text.indexOf("404") > -1) {
        url = error_text.match(/Got 404 response status from ([\w:\/.?=]+),/)[1];
        string += "<p>Error 404: Could not find a project with the specified information</p> <p>URL: " + url + "</p>";
      }
    }
    else if (project_type === "TravisProject") {
      string += "<p>Could not find a Travis Project with the Github Account / Repository Name combination entered."+
      "Please check the input and verify that it mactches your Travis CI account</p>"
    }
    else if (project_type === "TeamCityRestProject" || project_type === "TeamCityProject") {
      if (error_text.indexOf("401") > -1) {
        string += "<p>Error 401: Authentication error. Check to make sure you are using the correct username and password</p>"
      }
      if (error_text.indexOf("404") > -1) {
        url = error_text.match(/Got 404 response status from ([\w:\/.?=]+),/)[1];
        string += "<p>Error 404: Could not find a project with the specified information</p> <p>URL: " + url + "</p>";
      }
    }
    else if (project_type === "SemaphoreProject") {
      if (error_text.indexOf(757) > -1) {
        string += "<p>Error 757: Unexpected token in request</p>"
      }
    }

    if (string === "") {
      string += error_text
    }
    return string
  };


  o.validateFeedUrl = function () {
    $('.success, .failure, .unconfigured, .empty_fields', '#polling').addClass('hide');

    if ($('#project_type').val() === "") {
      $('#build_status .unconfigured').removeClass('hide');
      return;
    }

    var $inputs = $('#field_container :input:not(button):not(.hide):not(.optional):not([type=hidden]):enabled');
    if (_.some($inputs, isEmpty)) {
      if (_.every($inputs, isEmpty)) {
        $('#polling .unconfigured').removeClass('hide');
      } else {
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
          $('.error-message').addClass('hide');
        }
        else {
          $('#polling .pending').addClass('hide');
          $('#polling .failure').removeClass('hide').attr("title",result.error_type + ": '" + result.error_text + "'");
          $('.error-message').html(humanReadableErrorHTML(result)).removeClass('hide');
        }
      },
      error: function (result) {
        $('#polling .pending').addClass('hide');
        $('#polling .failure').removeClass('hide').attr("title","Server Error");
        $('.error-message').html("Server Error. Check your connection to the server").removeClass('hide');
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
    $('.error-message').addClass('hide');

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

  var enablePasswordField = function () {
    $('#change_password').addClass('hide');
    $('#project_auth_password').removeAttr('disabled');
    $('#project_auth_password').focus();
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
    $('#change_password').click(enablePasswordField);

    $(document).ready(o.setProviderSpecificVisibility); // To handle redirect back to page after following link

    o.setProjectTypeVisibility($('#project_type').val());

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
