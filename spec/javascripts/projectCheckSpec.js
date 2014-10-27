describe("ProjectCheck", function() {
  beforeEach(function() {
    jasmine.Ajax.install();
  });

  afterEach(function() {
    jasmine.Ajax.uninstall();
  });

  describe('init', function() {
    it('should make an Ajax call to get the list of projects as JSON', function() {
      ProjectCheck.init();

      expect(jasmine.Ajax.requests.count()).toEqual(1);
      expect(jasmine.Ajax.requests.first().url).toBe('/?');
      expect(jasmine.Ajax.requests.first().requestHeaders.Accept).toContain('application/json');
    });
  });

  describe('checkProjects', function() {
    it('should make an Ajax call to get the list of projects as JSON', function() {
      ProjectCheck.checkProjects();

      expect(jasmine.Ajax.requests.count()).toEqual(1);
      expect(jasmine.Ajax.requests.first().url).toBe('/?');
      expect(jasmine.Ajax.requests.first().requestHeaders.Accept).toContain('application/json');
    });

    describe('when the project list has not changed', function() {
      beforeEach(function(){
        spyOn(ProjectMonitor.Window, 'reload');
        spyOn($, 'ajax').and.callFake(function(options) {
          options.success([{project_id: 1}]);
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

        spyOn($, 'ajax').and.callFake(function(options) {
          options.success([]);
        });

        ProjectCheck.init();

        $.ajax.and.callFake(function(options) {
          options.success([{project_id: 1}]);
        });
      });

      it('should reload the page (in Firefox)', function() {
        ProjectCheck.checkProjects();
        expect(ProjectMonitor.Window.reload).toHaveBeenCalled();
      });
    });
  });
});
