// Event simulate (by kangax)
/**
 * Event.simulate(@element, eventName[, options]) -> Element
 * 
 * - @element: element to fire event on
 * - eventName: name of event to fire (only MouseEvents and HTMLEvents interfaces are supported)
 * - options: optional object to fine-tune event properties - pointerX, pointerY, ctrlKey, etc.
 *
 *    $('foo').simulate('click'); // => fires "click" event on an element with id=foo
 *
 **/
(function(){
  
  var eventMatchers = {
    'HTMLEvents': /^(?:load|unload|abort|error|select|change|submit|reset|focus|blur|resize|scroll)$/,
    'MouseEvents': /^(?:click|mouse(?:down|up|over|move|out))$/
  }
  var defaultOptions = {
    pointerX: 0,
    pointerY: 0,
    button: 0,
    ctrlKey: false,
    altKey: false,
    shiftKey: false,
    metaKey: false,
    bubbles: true,
    cancelable: true
  }
  
  Event.simulate = function(element, eventName) {
    var options = Object.extend(defaultOptions, arguments[2] || { });
    var oEvent, eventType = null;
    
    element = $(element);
    
    for (var name in eventMatchers) {
      if (eventMatchers[name].test(eventName)) { eventType = name; break; }
    }
 
    if (!eventType)
      throw new SyntaxError('Only HTMLEvents and MouseEvents interfaces are supported');
 
    if (document.createEvent) {
      oEvent = document.createEvent(eventType);
      if (eventType == 'HTMLEvents') {
        oEvent.initEvent(eventName, options.bubbles, options.cancelable);
      }
      else {
        oEvent.initMouseEvent(eventName, options.bubbles, options.cancelable, document.defaultView, 
          options.button, options.pointerX, options.pointerY, options.pointerX, options.pointerY,
          options.ctrlKey, options.altKey, options.shiftKey, options.metaKey, options.button, element);
      }
      element.dispatchEvent(oEvent);
    }
    else {
      options.clientX = options.pointerX;
      options.clientY = options.pointerY;
      oEvent = Object.extend(document.createEventObject(), options);
      element.fireEvent('on' + eventName, oEvent);
    }
    return element;
  }
  
  Element.addMethods({ simulate: Event.simulate });
})();

Screw.Matchers["be_same_element"] = {
  match: function(expected, actual) {
    return expected == actual;
  },
  failure_message: function(expected, actual, not) {
    return 'expected ' + jQuery.print(actual) + (not ? ' not' : '') + ' to be be same element as ' + jQuery.print(expected);
  }
}

Object.extend(Screw.Matchers, {
  be_same_element: {
    match: function(expected, actual) {
      return expected == actual;
    },
    
    failure_message: function(expected, actual, not) {
      return 'expected ' + jQuery.print(actual) + (not ? ' not' : '') + ' to be be same element as ' + jQuery.print(expected);
    }
  },
  
  have_class_name: {
    match: function(className, element) {
      return element.hasClassName(className);
    },
    
    failure_message: function(expected, actual, not) {
      return 'expected ' + jQuery.print(actual) + (not ? ' not' : '') + ' to have class name: ' + jQuery.print(expected);
    }
  },
  
  have_same_elements: {
    match: function(set1, set2) {
      var elementIsIn = function(element) { return set2.include(element); }
      return $A(set1).all(elementIsIn);
    },
    
    failure_message: function(expected, actual, not) {
      return 'expected both sets of elements to ' + (not ? 'not' : '') + ' be the same';
    }
  },
  
  be_zero: {
    match: function(expected, actual) {
      return actual == 0;
    },
    
    failure_message: function(expected, actual, not) {
      return 'expected ' + jQuery.print(actual) + (not ? ' not' : '') + ' to be zero'
    }
  }
})

var createCarousel = function() {
  return new Pivotal.Carousel("horizontal-carousel", {
    itemWidth: '80px',
    itemHeight: '40px'
  });
}

var fnTest = function(element) {
  element = $(element);
  element.update('ok!');
  element.stopObserving();
  element.observe('click', Event.stop);
}

