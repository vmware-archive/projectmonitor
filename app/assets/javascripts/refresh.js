var refreshTimeout = 60 * 1000; // 1 minute
var currentTimeout = null;

var refresh, scheduleRefresh;

refresh = function() {
  $(".project:not(.empty-project)").each(function(index,element) {
    var current_classes = $(element).attr("class");
    var projectCssId = $(element).attr("id");
    var project_id = $(element).data('id');
    var project_type = $(element).hasClass('aggregate') ? 'aggregate_project' : 'project';
    $.ajax({
      url: '/'+project_type+'s/'+project_id+'/status',
      method: 'GET',
      complete: function(data) {
        $('#' + projectCssId).replaceWith(data.responseText);
        $('#' + projectCssId).attr("class", current_classes);
      }
    });
  });
  scheduleRefresh();
};

scheduleRefresh = function () {
  clearTimeout(currentTimeout);
  currentTimeout = setTimeout(refresh, refreshTimeout);
};

$(function(){
  scheduleRefresh();
});
