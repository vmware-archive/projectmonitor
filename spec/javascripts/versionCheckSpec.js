describe('init', function() {
  it('should make an Ajax call to get the curent revision', function() {
    VersionCheck.init();

    expect(ajaxRequests.length).toEqual(1);
    expect(ajaxRequests[0].url).toBe('/revision');
  });

  describe('when the API has been stubbed', function() {
    var currentVersion = 1;

    beforeEach(function() {
      spyOn($, 'ajax').andCallFake(function(options) {
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
  it('should make an Ajax call to get the current revision', function() {
    VersionCheck.checkVersion();

    expect(ajaxRequests.length).toEqual(1);
    expect(ajaxRequests[0].url).toBe('/revision');
  });

  describe('when the version has not been set', function() {
    var currentVersion = 1;

    beforeEach(function() {
      spyOn(WindowManager, 'reload')
      spyOn($, 'ajax').andCallFake(function(options) {
        options.success(currentVersion);
      });
      delete window.currentVersion;
    });

    it('should not have a current version', function() {
      expect(VersionCheck.currentVersion()).toBeUndefined();
    });

    it('should reload the page (in Firefox)', function() {
      VersionCheck.checkVersion();

      expect(WindowManager.reload).toHaveBeenCalled();
    });
  });

  describe('when the version has not changed', function() {
    var currentVersion = 1;

    beforeEach(function() {
      spyOn(WindowManager, 'reload');
      spyOn($, 'ajax').andCallFake(function(options) {
        options.success(currentVersion);
      });
      VersionCheck.init();
      VersionCheck.checkVersion();
    });

    it('should not reload the page (in Firefox)', function() {
      expect(WindowManager.reload).not.toHaveBeenCalled();
    });
  });

  describe('when the version has changed', function() {
    var currentVersion = 1;

    beforeEach(function() {
      spyOn(WindowManager, 'reload');
      spyOn($, 'ajax').andCallFake(function(options) {
        options.success(currentVersion++);
      });
      VersionCheck.init();
      VersionCheck.checkVersion();
    });

    it('reloads the page (in Firefox)', function() {
      expect(WindowManager.reload).toHaveBeenCalled();
    });
  });
});
