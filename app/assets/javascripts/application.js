//= require jquery
//= require jquery_ujs
//= require jquery_ui
//= require underscore
//= require backbone
//= require backbone_rails_sync
//= require backbone_datalink
//= require backbone/project_monitor
//= require Coccyx
//= require autocomplete
//= require tagSwitcher
//= require backtraceHide
//= require projectEdit
//= require versionCheck
//= require projectCheck
//= require githubRefresh
//= require herokuRefresh
//= require rubygemsRefresh

$(function() {
  ProjectEdit.init();
  BacktraceHide.init();
  TagSwitcher.init();
  VersionCheck.init();
  ProjectCheck.init();
  GithubRefresh.init();
  HerokuRefresh.init();
  RubyGemsRefresh.init();
});
