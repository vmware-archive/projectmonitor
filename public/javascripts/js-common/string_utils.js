StringUtils = {

    // use String.trim() instead...
    trim: function(text) {
        return text.replace(/^\s+|\s+$/g,"");
    },

    stripWhitespace: function(text) {
        return text.replace(/\s+/g, "");
    },

    isWhitespace: function(text) {
        return this.trim(text).length == 0;
    },

    capitalize: function(string) {
      if (!string) {
        return string;
      }
      return string.charAt(0).toUpperCase() + string.substring(1);
    },

    underscored: function(str) {
      return str.gsub( / /, '_' );
    },

    commaDelimitedStringToArray: function(str) {
      resultArray = $A(str.split(","));
      return StringUtils.trimStringsInArray(resultArray);
    },

    trimStringsInArray: function(arr) {
    if (arr == null) return [];
    trimmedArray = arr.collect(function(foo) {
      return foo.strip();
    });
    return trimmedArray.reject(function(foo) {return foo == ""});
    },

    sortIgnoreCase: function(array) {
      return array.sort(function(string1,string2) {
        var aName = string1.toLowerCase();
        var bName = string2.toLowerCase();
         if (aName < bName) {
          return -1;
        } else if (aName > bName) {
          return 1;
        } else {
          return 0;
        }
      }.bind(this));
    }
};

var StringSorter = Class.create();
StringSorter.prototype = {
  initialize: function(stringsInOrder) {
    this.order = {};
    for (var i=0; i<stringsInOrder.length; ++i) {
      this.order[stringsInOrder[i]] = i;
    }
  },

  sort: function(array) {
    return array.sort(function(a,b) {
      return this.orderOf(a) - this.orderOf(b);
    }.bind(this));
  },

  orderOf: function(string) {
    if (this.order[string] == undefined) {
      return 99999;
    } else {
      return this.order[string];
    }
  }
};
