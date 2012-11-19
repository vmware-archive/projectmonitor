//= require versionCheck
//= require projectCheck
//= require projectRefresh
//= require githubRefresh
//= require herokuRefresh

$(function() {
  VersionCheck.init();
  ProjectCheck.init();
  ProjectRefresh.init();
  GithubRefresh.init();
  HerokuRefresh.init();

  $(document).bind("ajaxStart", function() {
    $('#indicator').removeClass('idle');
  });

  $(document).bind("ajaxStop", function() {
    $('#indicator').addClass('idle');
  });
});
