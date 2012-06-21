var refreshTimeout = 60 * 1000; // 1 minute
var currentTimeout = null;
var refresh, scheduleRefresh;

refresh = function() {
  $(".project:not(.empty-project)").each(function(index,element) {
    var projectCssId = $(element).attr("id");
    var project_id = $(element).data('id');
    var project_type = $(element).hasClass('aggregate') ? 'aggregate_project' : 'project';
    var projects_count = $("body").attr("class").split(" ").slice(-1)[0].split("_").slice(-1)[0];
    $.ajax({
      url: '/'+project_type+'s/'+project_id+'/status',
      data: { projects_count: projects_count },
      method: 'GET',
      dataType: 'html',
      success: function(response) {
        $('#' + projectCssId).replaceWith(response);
        if ($('body').hasClass('tiles_15')) {
          $('.building-indicator').spin({radius:8, length:9, width:3, lines:12, top:2, left:16});
        }
        else if ($('body').hasClass('tiles_48')) {
          $('.building-indicator').spin({radius:4, length:6, width:1, lines:12, top:1, left:10});
        }
        else if ($('body').hasClass('tiles_63')) {
          $('.building-indicator').spin({radius:4, length:4, width:1, lines:12, top:3, left:12});
        }
        else {
          $('.building-indicator').spin({radius:6, length:7, width:2, lines:12, top:4, left:6});
        }
      },
      error: function() {
        $('#' + projectCssId).addClass("server-unreachable");
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
  $(document).bind("ajaxStart", function() {
    $('#indicator').removeClass('idle');
  });

  $(document).bind("ajaxStop", function() {
    $('#indicator').addClass('idle');
  });

  scheduleRefresh();
});
