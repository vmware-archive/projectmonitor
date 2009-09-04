var SimpleHtmlBuilder = function() {
  this.parts = [];
}

SimpleHtmlBuilder.prototype = {
  open: function(elementType, attributes) {
    var parts = this.parts;
    parts.push("<");
    parts.push(elementType);

    for (var attribute in attributes) {
      parts.push(" ");
      if (attribute === "className") {
        parts.push("class");
      } else if (attribute == "htmlFor") {
        parts.push("for")
      } else {
        parts.push(attribute);
      }

      parts.push("=\"");
      parts.push(attributes[attribute]);
      parts.push("\"");
    }
    parts.push(">");
  },

  close: function(elementType) {
    var parts = this.parts;
    parts.push("</");
    parts.push(elementType);
    parts.push(">");
  },

  html: function(contents) {
    this.parts.push(contents);
  },

  toString: function() {
    return this.parts.join("");
  }
};