var DomBuilder = function(params) {
  var that = this;
  var objectParams = {
    parent: null,
    binding: this
  };
  objectParams = DomBuilder.extend(objectParams, params);
  this.parent = objectParams.parent;

  var currentElement;
  if(this.parent) currentElement = this.parent;
  var elements = [this.parent];
  this.binding = objectParams.binding;
  this.createElement = DomBuilder.createElement;
  this.createTextNode = DomBuilder.createTextNode;

  this.tag = function(tagName) {
    var arity = arguments.length;
    var element = null;
    if(arity == 1) {
      element = tagWithOneArgument(tagName);
    }
    else if(arity == 2) {
      element = tagWithTwoArguments(tagName, arguments[1]);
    }
    else if(arity == 3) {
      element = tagWithThreeArguments(tagName, arguments[1], arguments[2]);
    }
    else {
      throw "Invalid number of arguments";
    }
    return element;
  }

  this.appendText = function(text) {
    appendTextToElement(currentElement, text);
  }

  this.tagWithArrayArgs = function(tag, args) {
    if(!args) return this.tag(tag);

    var newArguments = [tag];
    for(var i=0; i < args.length; i++) {
      newArguments.push(args[i]);
    }
    return this.tag.apply(this, newArguments);
  }

  this.appendXml = function(xml) {
    currentElement.innerHTML += xml;
  }

  function tagWithOneArgument(tagName) {
    var element = that.createElement(tagName);
    appendChild(element);
    return element;
  };

  function tagWithTwoArguments(tagName, secondArgument) {
    var element = null;
    if(typeof secondArgument == 'function') {
      element = renderAttributesAndFunction(tagName, null, secondArgument);
    }
    else if(typeof secondArgument == 'string') {
      element = renderAttributesAndText(tagName, null, secondArgument);
    }
    else {
      element = that.createElement(tagName, secondArgument);
      appendChild(element);
    }
    return element;
  };

  function tagWithThreeArguments(tagName, attributes, thirdArgument) {
    var element = null;
    if(typeof thirdArgument == 'function') {
      element = renderAttributesAndFunction(tagName, attributes, thirdArgument);
    }
    else {
      element = renderAttributesAndText(tagName, attributes, thirdArgument);
    }
    return element;
  };

  function renderAttributesAndFunction(tagName, attributes, theFunction) {
    var element = that.createElement(tagName, attributes);
    pushElement(element);
    theFunction.call(that.binding, that);
    popElement();
    return element;
  }

  function renderAttributesAndText(tagName, attributes, text) {
    var element = that.createElement(tagName, attributes);
    pushElement(element);
    that.appendText((text) ? text.toString() : "");
    popElement();
    return element;
  }

  function appendTextToElement(element, text) {
    var node = that.createTextNode(text);
    element.appendChild(node);
  }

  function pushElement(element) {
    appendChild(element);
    elements.push(element);
    currentElement = element;
  }

  function appendChild(element) {
    if(currentElement) {
      try {
        currentElement.appendChild(element);
      }
      catch(e) {
        throw "Current element does not support appendChild";
      }
    }
  }

  function popElement(element) {
    element = elements.pop();
    var length = elements.length;
    if(length == 0) {
      currentElement = null;
    }
    else {
      currentElement = elements[elements.length - 1];
    }
    return element;
  }
}
DomBuilder.initialize = function(document) {
  var that = this;
  this.createElement = function(tagName, attributes) {
    var element = document.createElement(tagName);
    for(var key in attributes) {
      var value = attributes[key];
      try {
        setAttributeOnElement(element, key, value);
      }
      catch(e) {
        throw(
          "Error while trying to create an element with the attribute " +
          key + " and value " + value + ": " + e
        );
      }
    };
    return element;
  };

  this.createTextNode = function(text) {
    return document.createTextNode(text);
  };

  this.registerTag = function(tagName) {
    DomBuilder.prototype[tagName] = function() {
      return this.tagWithArrayArgs(tagName, arguments);
    };
  }

  this.extend = function(destination, source) {
    for(var property in source) {
      destination[property] = source[property];
    }
    return destination;
  }

  function setAttributeOnElement(element, attributeName, attributeValue) {
    if(attributeName == "class") {
      setCssClassOnElement(element, attributeValue);
    }
    else if(attributeName == "style") {
      setStylesOnElement(element, attributeValue);
    }
    else {
      element.setAttribute(attributeName, attributeValue);
    }
  }

  function setCssClassOnElement(element, className) {
    element.className = className;
  }

  function setStylesOnElement(element, stylesString) {
    var styles = stylesString.split(";");
    for(var i = 0; i < styles.length; i++) {
      var styleString = strip(styles[i]);
      if(styleString.length == 0) continue;

      var keyValue = styleString.split(':', 2);
      var styleKey = strip(keyValue[0]);
      var styleValue = strip(keyValue[1]);
      if (styleKey.length > 0 && styleValue.length > 0) {
        if(styleKey.toLowerCase() == "float") {
          element.style["cssFloat"] = element.style["styleFloat"] = styleValue;
        }
        else {
          element.style[styleKey] = styleValue;
        }
      }
    }
  }
  
  function strip(str) {
    return str.replace(/^\s+/, '').replace(/\s+$/, '');
  }

  var supportedTags = [
    'a', 'acronym', 'address', 'area', 'b', 'base', 'bdo', 'big', 'blockquote', 'body',
    'br', 'button', 'caption', 'cite', 'code', 'dd', 'del', 'div', 'dl', 'dt', 'em',
    'fieldset', 'form', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'head', 'hr', 'html', 'i',
    'img', 'iframe', 'input', 'ins', 'kbd', 'label', 'legend', 'li', 'link', 'map',
    'meta', 'noframes', 'noscript', 'ol', 'optgroup', 'option', 'p', 'param', 'pre',
    'samp', 'script', 'select', 'small', 'span', 'strong', 'style', 'sub', 'sup',
    'table', 'tbody', 'td', 'textarea', 'th', 'thead', 'title', 'tr', 'tt', 'ul', 'var'
  ];
  for(var i=0; i < supportedTags.length; i++) {
    var tag = supportedTags[i];
    this.registerTag(tag);
  }  
}
DomBuilder.initialize.call(DomBuilder, document);