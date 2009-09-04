function fireEvent(element, eventName, relatedElement, options) {
    options = options || {};
    if (typeof(document.fireEvent) != 'undefined') {
        // IE - should work on all events
        if (element.parentNode == null) {
          document.body.appendChild(element);
        }
        var eventObj = document.createEventObject();
        if (eventName == 'mouseout' || eventName == 'mouseover' || eventName == 'mousedown' || eventName == 'mouseup' || eventName == 'mousemove') {
            if (relatedElement != null) {
              eventObj.toElement = relatedElement;
            }
            eventObj.clientX = options.x || 0;
            eventObj.clientY = options.y || 0;
            eventObj.screenX = options.x || 0;
            eventObj.screenY = options.y || 0;
            eventObj.x = options.x || 0;
            eventObj.y = options.y || 0;
            eventObj.button = options.button;
        } else if (eventName == 'click') {
            // in ie, simply firing the event will not click a checkbox. This may also happen for radios.
            if (element.type == 'checkbox') {
              element.checked = !element.checked;
            }
        }

        if (options.keyCode) {
          eventObj.keyCode = options.keyCode;
        }
        element.fireEvent('on' + eventName, eventObj);
    } else if (BrowserDetect.browser == "Safari") {
        var event = document.createEvent("MouseEvents");
        event.initEvent(eventName, true, true);
        element.dispatchEvent(event);
    } else if (typeof(document.createEvent) != 'undefined') {
        // Mozilla - mouse events only supported right now
        var evt;
        if (eventName == 'click' || eventName == 'dblclick' || eventName == 'mousedown' || 
            eventName == 'mouseup') {
            evt = document.createEvent('MouseEvents');
            evt.initMouseEvent(eventName, true, true, document.defaultView,
                0, options.x || 0, options.y || 0, options.x || 0, options.y || 0,
                false, false, false, false, 0, element);
        } else if (eventName == 'mouseover' || eventName == 'mouseout') {
            evt = document.createEvent('MouseEvents');
            evt.initMouseEvent(eventName, true, true, document.defaultView,
                0, 0, 0, 0, 0,
                false, false, false, false, 0, relatedElement);
        } else if (eventName == 'mousemove') {
            evt = document.createEvent('MouseEvents');
            evt.initMouseEvent(eventName, true, true, document.defaultView,
                0, options.x, options.y, options.x, options.y,
                false, false, false, false, 0, relatedElement);
        } else if (eventName == 'change' || eventName == 'submit' || eventName == 'load') {
            evt = document.createEvent('Events');
            evt.initEvent(eventName, true, true);
        } else if (eventName == 'focus' || eventName == 'blur') {
            evt = document.createEvent('Events');
            evt.initEvent(eventName, false, false);
        } else if (eventName == 'keypress' || eventName == 'keydown' || eventName == 'keyup') {
            evt = document.createEvent('KeyboardEvent');
            if (typeof(evt.initKeyboardEvent) != 'undefined') {
              evt.initKeyboardEvent(eventName, true, true, window, false, false, false, false, options.keyCode, options.keyCode);
            } else {
              evt.initKeyEvent(eventName, true, true, window, false, false, false, false, options.keyCode, options.keyCode);
            }
        } else {
            throw new Error("The fireEvent test helper function does not yet know what to do with eventName " + eventName + ", so define it accordingly.");
        }
        element.dispatchEvent(evt);
	    assertEquals("Element should match", element, Event.element(evt));
	    //assertEquals("Related element should match", relatedElement, YAHOO.util.Event.getRelatedTarget(evt));
    } else {
      // other browsers - untested.  Wonder if camelcase or all-lowercase is better?
      if (element['on' + eventName] != null) {
        element['on' + eventName]();
      } else {
        throw new Error("Could not find method for event " + eventName);
      }
    }
};

