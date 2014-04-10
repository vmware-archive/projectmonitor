var ProjectFilters = {};

(function(o) {
  var $select, $projectTable;

  o.init = function () {
    $select = $("select#tag");
    $projectTable = $("table.projects");

    if ($select.length > 0) {
      $select.change(o.filterProject);
    }
  };

  o.filterProject = function() {
    var tag = $select.val();

    _.each($projectTable.find("tbody tr"), function(tr) {
      if(!tag || _.contains($(tr).data("tags"), tag)) {
        $(tr).show();
      } else {
        $(tr).hide();
      }
    })
  };
})(ProjectFilters);