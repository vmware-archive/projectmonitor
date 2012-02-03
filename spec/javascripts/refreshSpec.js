var refreshDropdownHTML = '<select name="refreshInterval" id="refreshInterval"><option value="15">15 seconds</option> <option value="30">30 seconds</option> <option value="60">60 seconds</option> <option value="300">5 minutes</option> <option value="0">Never</option></select>'
describe('scheduleRefresh()', function () {
  describe('with a cookie set', function() {
    beforeEach(function() {
      createCookie("refreshTimeout","30", 1);
    });

    it('should set the refresh timeout to the cookie value', function() {
      spyOn(window, 'setTimeout').andReturn("fakeHandle");
      scheduleRefresh();
      expect(window.setTimeout).wasCalledWith("refresh();", 30000);
      expect(window.currentTimeout).toEqual("fakeHandle")
    });
  });

  describe('with cookie set to 0', function() {
    beforeEach(function() {
      createCookie("refreshTimeout","0", 1);
    })

    it('should not refresh', function() {
      spyOn(window, 'setTimeout');
      scheduleRefresh();
      expect(window.setTimeout).wasNotCalled();
    });
  });

  describe('with no cookie set', function() {
    beforeEach(function() {
      eraseCookie("refreshTimeout");
      expect(readCookie("refreshTimeout")).toBeNull();
    });

    it('should set the refresh timeout to 60 seconds', function() {
      spyOn(window, 'setTimeout');
      scheduleRefresh();
      expect(window.setTimeout).wasCalledWith("refresh();", 60000);
    });
  });
});

describe('setRefreshIntervalDropdown()', function() {
  beforeEach(function() {
    document.getElementById('jasmine_content').innerHTML = refreshDropdownHTML;
  });

  describe('with a cookie set', function() {
    it("should select the option in the dropdown that corresponds with the cookie", function() {
      createCookie("refreshTimeout", "30", 1);
      expect(document.getElementById("refreshInterval").value).toNotEqual("30");
      setRefreshIntervalDropdown();
      expect(document.getElementById("refreshInterval").value).toEqual("30");
    })
  });

  describe("without a cookie set", function() {
    it("should select the option in the dropdown that corresponds with the default", function() {
      eraseCookie("refreshTimeout");
      expect(document.getElementById("refreshInterval").value).toNotEqual("60");
      setRefreshIntervalDropdown();
      expect(document.getElementById("refreshInterval").value).toEqual("60");
    })
  })

})

describe('onChangeRefreshTimeoutDropdown', function() {
  beforeEach(function() {
    document.getElementById('jasmine_content').innerHTML = refreshDropdownHTML;
  });

  it("should copy refreshTimeout from dropdown to cookie", function() {
    document.getElementById("refreshInterval").value = "300";
    onChangeRefreshTimeoutDropdown();
    expect(readCookie("refreshTimeout")).toEqual("300");
  });

  it("should set the timeout to new value", function() {
    window.currentTimeout = "fakeHandle"
    document.getElementById("refreshInterval").value = "300";
    spyOn(window, "setTimeout");
    spyOn(window, "clearTimeout");
    onChangeRefreshTimeoutDropdown();
    expect(window.setTimeout).wasCalledWith("refresh();", 300000);
    expect(window.clearTimeout).wasCalledWith("fakeHandle");
  })
});

describe('refresh', function() {
  var spyOnGet;
  beforeEach(function() {
   var $ = jQuery.noConflict();
   var fixtures = '' +
       '<div class="projects">' +
           '<div class="project">' +
           '    <div class="box" project_id="1"/>' +
           '</div>' +
            '<div class="project aggregate">' +
           '    <div class="box" project_id="1"/>' +
           '</div>' +
           '<div class="project message">'+
                '<div class="box" message_id="1"/>'+
                '<div class="tweets" tweet_id="1"/>'+
           '</div>' +
       '</div>';
   spyOnGet = spyOn(jQuery, "get");
   spyOn(window, "scheduleRefresh");
   setFixtures(fixtures);

  });

  afterEach(function(){
    jQuery.get.reset();
  });

  it("should call $.get for the project", function() {
         refresh();
    expect(spyOnGet).toHaveBeenCalled();
    expect(spyOnGet.argsForCall[0][0]).toBe("projects/1/load_project_with_status");
    expect(spyOnGet.argsForCall[1][0]).toBe("messages/1/load_message");
    expect(spyOnGet.argsForCall[2][0]).toBe("aggregate_projects/1/load_aggregate_project_with_status");
    expect(spyOnGet.argsForCall[3][0]).toBe("twitter_searches/1/load_tweet");
    expect(window.scheduleRefresh).toHaveBeenCalled();
  });

});
