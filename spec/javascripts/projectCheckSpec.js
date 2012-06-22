describe('init', function() {
  it('should make an Ajax call to get the list of projects as JSON', function() {
    ProjectCheck.init();

    expect(ajaxRequests.length).toEqual(1);
    expect(ajaxRequests[0].url).toBe('/');
    expect(ajaxRequests[0].requestHeaders.Accept).toContain('application/json');
  });
});

describe('checkProjects', function() {
  it('should make an Ajax call to get the list of projects as JSON', function() {
    ProjectCheck.checkProjects();

    expect(ajaxRequests.length).toEqual(1);
    expect(ajaxRequests[0].url).toBe('/');
    expect(ajaxRequests[0].requestHeaders.Accept).toContain('application/json');
  });

  describe('when the project list has not changed', function() {
    beforeEach(function() {
      spyOn(ProjectMonitor.Window, 'reload');
      spyOn($, 'ajax').andCallFake(function(options) {
        options.success([{hudson_project: {id: 1}}]);
      });
    });

    it('should not reload the page (in Firefox)', function() {
      ProjectCheck.init();
      ProjectCheck.checkProjects();
      expect(ProjectMonitor.Window.reload).not.toHaveBeenCalled();
    });
  });

  describe('when the project list has changed', function() {
    beforeEach(function() {
      spyOn(ProjectMonitor.Window, 'reload');

      spyOn($, 'ajax').andCallFake(function(options) {
        options.success([]);
      });

      ProjectCheck.init();

      $.ajax.andCallFake(function(options) {
        options.success([{hudson_project: {id: 1}}]);
      });
    });

    it('should reload the page (in Firefox)', function() {
      ProjectCheck.checkProjects();
      expect(ProjectMonitor.Window.reload).toHaveBeenCalled();
    });
  });
});
