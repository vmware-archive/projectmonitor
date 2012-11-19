//= require jquery
//= require jquery_ujs
//= require jquery_ui
//= require underscore
//= require projectMonitor
//= require projectEdit
//= require backtraceHide
//= require autocomplete
//= require tagSwitcher

$(function() {
  ProjectEdit.init();
  BacktraceHide.init();
  TagSwitcher.init();
});
