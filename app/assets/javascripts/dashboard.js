//= require application
//= require twitter
//= require versionCheck
//= require projectCheck
//= require projectRefresh
//= require spin

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
