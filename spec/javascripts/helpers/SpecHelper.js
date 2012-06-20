beforeEach(function() {
  WindowManager.reload = function() {
    throw(new Error("This should never be called from a Jasmine spec"));
  }

  jasmine.Ajax.useMock();
  clearAjaxRequests();
});
