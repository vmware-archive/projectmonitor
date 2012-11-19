//= require versionCheck
//= require projectCheck
//= require projectRefresh
//= require githubRefresh

$(function() {
  VersionCheck.init();
  ProjectCheck.init();
  ProjectRefresh.init();
  GithubRefresh.init();

  $(document).bind("ajaxStart", function() {
    $('#indicator').removeClass('idle');
  });

  $(document).bind("ajaxStop", function() {
    $('#indicator').addClass('idle');
  });
});
