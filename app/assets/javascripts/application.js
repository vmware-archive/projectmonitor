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

$(function() {
  ProjectEdit.init();
  BacktraceHide.init();
  TagSwitcher.init();
});
