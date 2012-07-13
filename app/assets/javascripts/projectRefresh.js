var ProjectRefresh = (function () {
  var projects, projectsCount, pollIntervalSeconds = 30, fadeIntervalSeconds = 3;

  function showAsBuilding (selector) {
    (function f(i) {
      if (i < (pollIntervalSeconds / fadeIntervalSeconds) - 1) {
        setTimeout(function() {
          $(selector).fadeTo(1000, 0.5).fadeTo(1000, 1);
          f(i + 1);
        }, fadeIntervalSeconds * 1000);
      }
    })(0);
  }

  return {
    init : function () {
      projects = $('.project:not(.empty-project)');
      projectsCount = parseInt($('body').data('tiles-count'), 10);
      $('li.building').each(function (i, li) {
        showAsBuilding(li);
      });
      setTimeout(this.refresh, pollIntervalSeconds * 1000);
    },

    refresh : function () {
      projects.each(function(i, el) {
        var $el = $(el),
            projectCssId = $el.attr('id'),
            project_id = $el.data('id'),
            project_type = $el.hasClass('aggregate') ? 'aggregate_project' : 'project';

        $.ajax({
          url: '/'+project_type+'s/'+project_id+'/status',
          data: {
            projects_count: projectsCount
          },
          dataType: 'html',
          success: function(response) {
            $el.replaceWith(response);
            if ($(response).hasClass('building')) {
              showAsBuilding('#' + projectCssId);
              $('#' + projectCssId).fadeTo(1000, 0.5).fadeTo(1000, 1);
            }
          },
          error: function() {
            $el.addClass('server-unreachable');
          }
        });
      });
      setTimeout(ProjectRefresh.refresh, pollIntervalSeconds * 1000);
    }
  };
})();
