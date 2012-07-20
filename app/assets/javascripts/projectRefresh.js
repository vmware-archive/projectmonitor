var ProjectRefresh = (function () {
  var projectSelectors, tilesCount, pollIntervalSeconds = 30, fadeIntervalSeconds = 3;

  function showAsBuilding (projectSelector) {
    var $projectEl = $(projectSelector);
    (function f(i) {
      if (i < (pollIntervalSeconds / fadeIntervalSeconds) - 1) {
        $projectEl.fadeTo(1000, 0.5).fadeTo(1000, 1);
        setTimeout(function() {
          f(i + 1);
        }, fadeIntervalSeconds * 1000);
      }
    })(0);
  }

  return {
    init : function () {
      projectSelectors = $.map($('.project:not(.empty-project)'), function(projectElement) {
        return '#' + $(projectElement).attr('id');
      });
      tilesCount = parseInt($('body').data('tiles-count'), 10);

      $('li.building').each(function (i, li) {
        showAsBuilding(li);
      });

      setTimeout(this.refresh, pollIntervalSeconds * 1000);
    },

    refresh : function () {
      $.each(projectSelectors, function(i, projectSelector) {
        var $projectEl = $(projectSelector),
            project_id = $projectEl.data('id'),
            project_type = $projectEl.hasClass('aggregate') ? 'aggregate_project' : 'project';

        $.ajax({
          url: '/' + project_type + 's/' + project_id + '/status',
          dataType: 'html',
          data: {
            tiles_count: tilesCount
          },
          timeout: (pollIntervalSeconds - 1) * 1000,
          success: function(response) {
            $projectEl = $projectEl.replaceWith(response);
            if ($projectEl.hasClass('building')) {
              showAsBuilding(projectSelector);
            }
          },
          error: function() {
            $projectEl.addClass('server-unreachable');
          }
        });
      });
      setTimeout(ProjectRefresh.refresh, pollIntervalSeconds * 1000);
    }
  };
})();
