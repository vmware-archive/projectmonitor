describe('init', function() {
  beforeEach(function() {
    jasmine.Ajax.install();
  });

  afterEach(function() {
    jasmine.Ajax.uninstall();
  });

  it('should make an Ajax call to get the curent version', function() {
    VersionCheck.init();

    expect(jasmine.Ajax.requests.count()).toEqual(1);
    expect(jasmine.Ajax.requests.first().url).toBe('/version');
  });

  describe('when the API has been stubbed', function() {
    var currentVersion = 1;

    beforeEach(function() {
      spyOn($, 'ajax').and.callFake(function(options) {
        options.success(currentVersion);
      });
      VersionCheck.init();
    });

    it('should set the current version', function() {
      expect(VersionCheck.currentVersion()).toEqual(currentVersion);
    });
  });
});

describe('checkVersion', function() {
  beforeEach(function() {
    jasmine.Ajax.install();
  });

  afterEach(function() {
    jasmine.Ajax.uninstall();
  });

  it('should make an Ajax call to get the current version', function() {
    VersionCheck.checkVersion();

    expect(jasmine.Ajax.requests.count()).toEqual(1);
    expect(jasmine.Ajax.requests.first().url).toBe('/version');
  });

  describe('when the version has not been set', function() {
    var currentVersion = 1;

    beforeEach(function() {
      spyOn(ProjectMonitor.Window, 'reload');
      spyOn($, 'ajax').and.callFake(function(options) {
        options.success(currentVersion);
      });
      delete window.currentVersion;
    });

    it('should not have a current version', function() {
      expect(VersionCheck.currentVersion()).toBeUndefined();
    });

    it('should reload the page (in Firefox)', function() {
      VersionCheck.checkVersion();

      expect(ProjectMonitor.Window.reload).toHaveBeenCalled();
    });
  });

  describe('when the version has not changed', function() {
    var currentVersion = 1;

    beforeEach(function() {
      spyOn(ProjectMonitor.Window, 'reload');
      spyOn($, 'ajax').and.callFake(function(options) {
        options.success(currentVersion);
      });
      VersionCheck.init();
      VersionCheck.checkVersion();
    });

    it('should not reload the page (in Firefox)', function() {
      expect(ProjectMonitor.Window.reload).not.toHaveBeenCalled();
    });
  });

  describe('when the version has changed', function() {
    var currentVersion = 1;

    beforeEach(function() {
      spyOn(ProjectMonitor.Window, 'reload');
      spyOn($, 'ajax').and.callFake(function(options) {
        options.success(currentVersion++);
      });
      VersionCheck.init();
      VersionCheck.checkVersion();
    });

    it('reloads the page (in Firefox)', function() {
      expect(ProjectMonitor.Window.reload).toHaveBeenCalled();
    });
  });
});
