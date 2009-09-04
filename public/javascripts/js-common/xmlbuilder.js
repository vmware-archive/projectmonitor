var XmlBuilder = function(params) {
  var that = this;
  var doc = [];

  if(!params) params = {};
  this.binding = params.binding || this;
  this.tag = function() {
    if(arguments.length > 3) {
      throw("XmlBulider#tag does not accept more than three arguments");
    }
    var tagName, attributes, value;
    tagName = arguments[0];

    var arg1 = arguments[1];
    if(typeof arg1 == 'object') {
      attributes = arg1;
      var arg2 = arguments[2];
      if(typeof arg2 == 'function' || typeof arg2 == 'string'){
        value = arg2;
      };
    } else if(typeof arg1 == 'function' || typeof arg1 == 'string'){
      value = arg1;
      var arg2 = arguments[2];
      if(typeof arg2 == 'object') {
        attributes = arg2;
      }
    };

    doc.push(new XmlBuilder.OpenTag(tagName, attributes));
    if(typeof value == 'function') {
      value.call(that.binding, that);
    } else if(typeof value == 'string') {
      doc.push(new XmlBuilder.Text(value));
    }
    doc.push(new XmlBuilder.CloseTag(tagName));
  }
  
  this.tagWithArrayArgs = function(tag, args) {
    if(!args) return this.tag(tag);

    var newArguments = [tag];
    for(var i=0; i < args.length; i++) {
      newArguments.push(args[i]);
    }
    return this.tag.apply(this, newArguments);
  }

  this.text = function(value) {
    doc.push(new XmlBuilder.Text(value));
  }

  this.textNode = function(value) {
    var html = this.escapeHtml(value);
    doc.push(new XmlBuilder.Text(html));
  }

  this.escapeHtml = function(html) {
    return html.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;")
  }

  this.toString = function() {
    var output = "";
    for(var i=0; i < doc.length; i++) {
      var element = doc[i];
      output += element.toString();
    }
    return output;
  }
}

XmlBuilder.initialize = function() {
  var that = this;

  this.registerTag = function(tagName) {
    that.prototype[tagName] = function() {
      return this.tagWithArrayArgs(tagName, arguments);
    };
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
XmlBuilder.initialize.call(XmlBuilder);

XmlBuilder.OpenTag = function(tagName, attributes) {
  var that = this;
  this.tagName = tagName;
  this.attributes = attributes;

  this.toString = function() {
    var serializedAttributes = [];
    for(var attributeName in attributes) {
      serializedAttributes.push(attributeName + '="' + attributes[attributeName] + '"');
    }
    if(serializedAttributes.length > 0) {
      return "<" + that.tagName + " " + serializedAttributes.join(" ") + ">";
    } else {
      return "<" + that.tagName + ">";
    }
  }
}

XmlBuilder.Text = function(value) {
  var that = this;
  this.value = value;

  this.toString = function() {
    return that.value;
  }
}

XmlBuilder.CloseTag = function(tagName) {
  var that = this;
  this.tagName = tagName;

  this.toString = function() {
    return "</" + that.tagName + ">";
  }
}