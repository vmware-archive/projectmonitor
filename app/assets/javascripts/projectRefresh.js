var ProjectRefresh = {};
(function (o) {
  function showAsBuilding ($el) {
    (function f(i) {
      if (i < 9) {
        setTimeout(function() {
          $el.fadeTo(1000, 0.5).fadeTo(1000, 1);
          f(i + 1);
        }, 3000);
      }
    })(0);
  }

  o.refresh = function () {
    setTimeout(function () {
      $(".project:not(.empty-project)").each(function(index,element) {
        var projectCssId = $(element).attr("id");
        var project_id = $(element).data('id');
        var project_type = $(element).hasClass('aggregate') ? 'aggregate_project' : 'project';
        var projectsCount = parseInt($("body").data("tiles-count"), 10);

        $.ajax({
          url: '/'+project_type+'s/'+project_id+'/status',
          data: { projects_count: projectsCount },
          method: 'GET',
          dataType: 'html',
          success: function(response) {
            var isBuilding = $(response).hasClass("building");
            $('#' + projectCssId).replaceWith(response);

            if (isBuilding) {
              showAsBuilding($('#' + projectCssId));
              $('#' + projectCssId).fadeTo(1000, 0.5).fadeTo(1000, 1);
            }
          },
          error: function() {
            $('#' + projectCssId).addClass("server-unreachable");
          }
        });
      });
      o.refresh();
    }, 30 * 1000);
  };

  o.init = function() {
    $('li.building').each(function (i, li) {
      showAsBuilding($(li));
    });
    o.refresh();
  };
})(ProjectRefresh);
