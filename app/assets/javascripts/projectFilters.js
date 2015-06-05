var ProjectFilters = {};

(function(o) {
  var $tagSelect, $pollingStatusSelect, $projectTable;

  o.init = function () {
    $tagSelect = $("select#tag");
    $pollingStatusSelect = $("select#polling_status");
    $projectTable = $("table.projects");

    $tagSelect.change(o.filterProject);
    $pollingStatusSelect.change(o.filterProject);
  };

  o.filterProject = function() {
    var tag = $tagSelect.val();
    var pollingStatus = $pollingStatusSelect.val();

    _.each($projectTable.find("tbody tr"), function(tr) {
      $(tr).show();

      if(tag && !_.contains($(tr).data("tags"), tag)) {
        $(tr).hide();
      }

      if(pollingStatus && pollingStatus != $(tr).data("polling-status")) {
        $(tr).hide();
      }
    })
  };
})(ProjectFilters);