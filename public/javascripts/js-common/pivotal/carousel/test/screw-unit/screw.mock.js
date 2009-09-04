/** @fileOverview
      A mocking framework for screw-unit.  Allows you to temporarily mock out
      functions with objects you are not testing.

      @author <a href="mailto:topper@toppingdesign.com">Topper Bowers</a>
*/

/** Test helper main namespace
    @namespace
*/
var TH = (function () {
    /** @namespace */
    var publicObj = {};
    
    /** used to insert a dom mock for the test being run
        assumes a <div> with an id of "dom_test" and directory
        of dom_mocks at the same level as suite.html called "dom_mocks"
        
        @param {String} mock the name of the mock to put into the div (you can skip the html)
        @param {Object} opts takes an optional insert or a specific element (instead of #dom_test)
        
        @throws mock must be specified if no mock is specified
        
        @example
          TH.insertDomMock("some_mock"); // will insert dom_mocks/some_mock.html into <div id='#dom_test'><div>
          
        @name TH.insertDomMock
        @function
    */
    publicObj.insertDomMock = function(mock, opts) {
        if (!mock) {
            throw new Error("mock must be specified");
        }
        opts = opts || {};
        
        var element = opts.element || jQuery("#dom_test");
        
        element = jQuery(element);
        if (!/\.html$/.test(mock)) {
            mock += ".html";
        }
        
        var url = "dom_mocks/" + mock;

        var handleResponse = function (html) {
            if (opts.insert) {
                element.append(html);
            } else {
                element.html(html);
            }
        };
        
        // use jQuery here so we can mock out Ajax.Request for the tests
        var ajx = jQuery.ajax({
            url: url,
            async: false,
            type: 'GET',
            success: handleResponse
        });
    };

    /** simulate a browser click on an element passed to the function
        @param {DomElement} el The element to receive the click
        
        @name TH.click
        @function
    */
    publicObj.click = function(el) {
        if(jQuery.browser.msie) {
          el.click();
        } else {
          var evt = document.createEvent("MouseEvents");
          evt.initEvent("click", true, true);
          el.dispatchEvent(evt);
        }
    };
    
    /** pause the operation of a page for X miliseconds
        @param {Number} millis the number of miliseconds to pause
        @name TH.pause
        @function
    */
    publicObj.pause = function (millis) {
        var date = new Date();
        var curDate = null;

        do { curDate = new Date(); }
        while(curDate-date < millis);
    };

    return publicObj;    
})();

/** Mock out objects using a fairly simple interface.  Also adds some counting functions.
    @example
      var someObj = {
          foo: function () { return 'bar' }
      };
      someObj.foo() == 'bar';
      TH.Mock.Obj("someObj", {
          foo: function () { return 'somethingElse' }
      });
      someObj.foo() == 'somethingElse'; // BUT!  Only for this test the next test will have a normal someObj;
      
    @example
      var someObj = {
          foo: function () { return 'bar' }
      };
      someObj.foo() == 'bar';
      TH.Mock.Obj("someObj");
      someObj.countCallsOf("foo");
      someObj.foo() == true;
      someObj.numberOfCallsTo("foo") == 1;
      // using that you can then do cool expectations:  expect(someObj.numberOfCallsTo("foo")).to(equal, 1);

    @namespace
*/
TH.Mock = (function () {
    /** @namespace */
    var publicObj = {};
    /** the mocked out objects
        @name TH.Mock.mockedObjects
    */
    publicObj.mockedObjects = {};
    
    /** taken from prototype - bind a function to a certain object
        @private
    */
    var bind = function(func, obj) {
        if (obj === undefined) return func;
        var __method = func, object = obj;
        return function() {
          return __method.apply(object, jQuery.makeArray(arguments));
        }
    };
    
    /** taken from prototype - copy one object to another
        @private
    */
    var extendObject = function (destination, source) {
        for (var property in source) {
            destination[property] = source[property];
        }
        return destination;
    };
    
    /** this is used as a constructor to make a new mocked object and cache it
        @private
        @constructs
    */
    var MockedObject = function (props) {
        extendObject(this, props);
        this.countCallsCache = {};
    };
    
    /** Adds the countCallsOf and numberOfCallsTo methods to any object that
        is getting mocked
        @private
    */
    MockedObject.prototype = {
        countCallsOf: function (propString) {
            this.countCallsCache[propString] = {};
            var prop = this.countCallsCache[propString];
            prop.count = 0;
            this[propString] = bind(function () {
                this.countCallsCache[propString].count++;
            }, this);         
        },
        numberOfCallsTo: function(propString) {
            return this.countCallsCache[propString].count;
        }
        
    };
    
    /** main mocking interface
        
        @param {String} mockString the string representation of the object you are trying to mock
        @param {Object} newObj (optional) functions you want to mock on the other object
    
        @throws if the mockString does not eval into an object
    
        @see TH.Mock
        @name TH.Mock.obj
        @function
    */
    publicObj.obj = function (mockString, newObj) {
        var oldObj = eval(mockString);
        var obj;
        if (!(typeof oldObj == "object")) {
            throw new Error("TH.Mock.obj called on a string that doesn't evaluate into an object");
        }
        obj = new MockedObject(oldObj);
        extendObject(obj, newObj);
        
        publicObj.mockedObjects[mockString] = {};
        publicObj.mockedObjects[mockString].newObj = obj;
        publicObj.mockedObjects[mockString].oldObj = oldObj;
        
        eval(mockString + " = TH.Mock.mockedObjects['" + mockString + "'].newObj");
        
        return obj;
    };
    
    /** Used in a before() to reset all the objects that have been mocked to their original splendor
        @name TH.Mock.reset
        @function
    */
    publicObj.reset = function () {
        var m;
        var obj;
        for (mockString in publicObj.mockedObjects) {
            if (publicObj.mockedObjects.hasOwnProperty(mockString)) {
                eval(mockString + " = TH.Mock.mockedObjects['" + mockString + "'].oldObj");
            }
        }
        publicObj.mockedObjects = {};
    };
    
    /** this will let you call TH.Mock.numberOfCallsTo("name", "prop") - for convenience
        @name TH.Mock.numberOfCallsTo
        @function
    */
    publicObj.numberOfCallsTo = function (mockString, propString) {
        var obj = eval(mockString);
        return obj.numberOfCallsTo(propString);
    };

    // for dev
    publicObj.dirMocks = function () {
        console.dir(mockCache);
    };
    
    publicObj.dirCountCalls = function () {
        console.dir(countCallsCache);
    };
    
    return publicObj;
})();

/** This mocks out Prototype's ajax calls so that you don't need a server in your tests
    @example
      TH.Ajax.mock("/a_url", "someText", 200);
      var ajx = new Ajax.Request("/a_url", {
          onComplete: function (resp) { response = resp }
      });
      expect(response.responseText).to(equal, "someText");
      
    @namespace
*/
TH.Ajax = (function () {
    /** @namespace */
    var publicObj = {};
    
    var mockAjaxHash = {};
    
    /** Lets you count the number of requests on a certain URL
        @example
          TH.Ajax.mock("/a_url", "someText", 200);
           var ajx = new Ajax.Request("/a_url", {
               onComplete: function (resp) { response = resp }
           });
           expect(TH.Ajax.requestCont["/a_url"]).to(equal, 1);
    
        @name TH.Ajax.requestCount
    */
    publicObj.requestCount = {};
    
    /** Reset the request count - used in a before()
        @name TH.Ajax.reset
        @function
    */
    publicObj.reset = function () {
        publicObj.requestCount = {};
    };
    
    /** this is the main mocking interface
        @param {String} urlToMock the url that you want to respond with your response
        @param {String} response the text you want the server to send back. Text will try to be
          evaled into JSON so that responseJSON can be set.
        @param {Number} status (optional) the response code you want the server to send
        
        @example
          TH.Ajax.mock("/a_url", "someText", 200);
          var ajx = new Ajax.Request("/a_url", {
              onComplete: function (resp) { response = resp }
          });
          expect(response.responseText).to(equal, "someText");
        
        @name TH.Ajax.mock
        @function
    */
    publicObj.mock = function (urlToMock, response, status) {
        status = status || 200;
        mockAjaxHash[urlToMock] = { response: response, status: status };
        
        Ajax = {};
        Ajax.Request = function(url, opts) {
            if (!mockAjaxHash.hasOwnProperty(url)) {
                throw new Error("ajax request called with: " + url + " but no mock was found");
            }
            
            if (!publicObj.requestCount[url]) {
                publicObj.requestCount[url] = 1;
            } else {
                publicObj.requestCount[url]++;
            }
            
            if(opts.onComplete || opts.onSuccess || opts.onFailure) {
                response = {};
                response.responseText = mockAjaxHash[url].response;
                response.status = mockAjaxHash[url].status;
                try {
                    response.responseJSON = response.responseText.evalJSON();
                } catch (e) {
                    response.responseJSON = null;
                }
                
                if ((response.status == 200) && opts.onSuccess) {
                    opts.onSuccess(response);
                } else {                    
                    if (opts.onFailure) {
                        opts.onFailure(response);
                    }
                }
                if (opts.onComplete) {
                    opts.onComplete(response);
                }
            }
        };
    };
    
    return publicObj;
})();

Screw.Unit(function() {
    before(function() {
        if ($("dom_test")) {
            $('dom_test').empty();
        }
        TH.Ajax.reset();
        TH.Mock.reset();
    });
});
