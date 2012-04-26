var refreshTimeout = 60 * 1000; // 1 minute
var currentTimeout = null;
var total = 0;
var refresh, scheduleRefresh;

refresh = function() {
  $('#indicator').removeClass('idle');
  total = $(".project:not(.empty-project)").length;

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
        refreshComplete();
      }
    });
  });
  scheduleRefresh();
};

scheduleRefresh = function () {
  clearTimeout(currentTimeout);
  currentTimeout = setTimeout(refresh, refreshTimeout);
};

refreshComplete = function() {
  total -= 1;
  if(total === 0) {
    $('#indicator').addClass('idle');
  }
};


$(function(){
  scheduleRefresh();
});
