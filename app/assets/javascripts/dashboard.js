//= require application
//= require versionCheck
//= require projectCheck
//= require projectRefresh

$(function() {
  VersionCheck.init();
  ProjectCheck.init();
  ProjectRefresh.init();

  $(document).bind("ajaxStart", function() {
    $('#indicator').removeClass('idle');
  });

  $(document).bind("ajaxStop", function() {
    $('#indicator').addClass('idle');
  });
});
