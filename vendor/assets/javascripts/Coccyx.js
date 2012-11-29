//     Coccyx.js 0.4.1

//     (c) 2012 Onsi Fakhouri
//     Coccyx.js may be freely distributed under the MIT license.
//     http://github.com/onsi/coccyx

(function() {
  var Coccyx;

  if (typeof exports !== 'undefined') {
    Coccyx = exports;
  } else {
    Coccyx = this.Coccyx = {};
  }

  Coccyx.enforceContextualBinding = false;
  Coccyx.enforceConstructorName   = false;

  Coccyx._globalTearDownCallbacks = [];
  Coccyx.addTearDownCallback = function(callback) {
    Coccyx._globalTearDownCallbacks.push(callback);
  };

  var originalExtend = Backbone.Model.extend;
  var coccyxExtend = function(protoProps, classProps) {
    var parent = this;
    if (Coccyx.enforceConstructorName && !protoProps.constructorName) throw "Coccyx: Attempted to create a new class without passing in a constructor name."
    if (protoProps.constructorName && !protoProps.hasOwnProperty('constructor')) {
      eval("protoProps.constructor = function " + protoProps.constructorName + " () { parent.apply(this, arguments) };");
    }
    return originalExtend.call(parent, protoProps, classProps);
  }

  var originalOn = Backbone.Events.on;
  var coccyxOn = function(events, callback, context) {
    var returnValue = originalOn.apply(this, arguments);
    if (Coccyx.enforceContextualBinding && !context) throw "Coccyx: Backbone event binding attempted without a context."
    if (context && context.registerEventDispatcher) context.registerEventDispatcher(this);
    return returnValue;
  }

  var coccyxViewExtensions = {
    registerEventDispatcher: function(dispatcher) {
      dispatcher._coccyxId = dispatcher._coccyxId || dispatcher.cid || _.uniqueId('coccyx');
      this.eventDispatchers = this.eventDispatchers || {};
      this.eventDispatchers[dispatcher._coccyxId] = dispatcher;
    },

    unregisterEventDispatcher: function(dispatcher){
      dispatcher.off(null, null, this);
      delete this.eventDispatchers[dispatcher._coccyxId];
    },

    registerSubView: function(subView) {
      this.subViews = this.subViews || {};
      this.subViews[subView.cid] = subView;
      subView.__parentView = this;
      return subView;
    },

    unregisterSubView: function(subView) {
      subView.__parentView = undefined;
      delete this.subViews[subView.cid];
    },

    tearDown: function() {
      this._tearDown();
      this.$el.remove();
      return this;
    },
    
    tearDownRegisteredSubViews: function() {
      _(this.subViews).invoke('_tearDown');
    },
    
    _tearDown: function() {
      var that = this;
      if (this.beforeTearDown) this.beforeTearDown();
      if (this.__parentView) this.__parentView.unregisterSubView(this);
      _(Coccyx._globalTearDownCallbacks).each(function(callback) {
        callback.apply(that);
      });
      this.undelegateEvents();
      this.__parentView = null;

      _(this.eventDispatchers).invoke('off', null, null, this);
      this.eventDispatchers = {};
      
      _(this.subViews).invoke('_tearDown');
      this.subViews = {};
    }
  }

  var klassNames = ['Model', 'Collection', 'Router', 'View'];

  var coccyxify = function(root) {
    Coccyx.root = root;
    root.Events = _.extend(root.Events, {on:coccyxOn, bind:coccyxOn});
    _.each(klassNames, function(klassName) {
      root[klassName].extend = coccyxExtend;
      _.extend(root[klassName].prototype, root.Events);
    });
    _.extend(root.View.prototype, coccyxViewExtensions);
  }
  
  coccyxify(Backbone);
})();