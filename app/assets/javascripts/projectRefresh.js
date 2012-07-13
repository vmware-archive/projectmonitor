var ProjectRefresh = (function () {
  var projects, projectsCount;

  function showAsBuilding (selector) {
    (function f(i) {
      if (i < 9) {
        setTimeout(function() {
          $(selector).fadeTo(1000, 0.5).fadeTo(1000, 1);
          f(i + 1);
        }, 3000);
      }
    })(0);
  }

  return {
    init : function () {
      projects = $('.project:not(.empty-project)');
      projectsCount = parseInt($('body').data('tiles-count'), 10);
      setTimeout(this.refresh, 30 * 1000);
      $('li.building').each(function (i, li) {
        showAsBuilding(li);
      });
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
      setTimeout(ProjectRefresh.refresh, 30 * 1000);
    }
  };
})();
