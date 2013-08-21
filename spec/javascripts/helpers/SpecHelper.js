//= require application

beforeEach(function() {
  $.fx.off = true;

  window.ProjectMonitor.Window.reload = function() {
    throw(new Error("This should never be called from a Jasmine spec"));
  }

  clearAjaxRequests();
});
