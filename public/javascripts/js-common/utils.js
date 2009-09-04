/* from quirksmode.org/js/detect.html */
var BrowserDetect = {
	init: function () {
		this.browser = this.searchString(this.dataBrowser) || "An unknown browser";
		this.version = this.searchVersion(navigator.userAgent)
			|| this.searchVersion(navigator.appVersion)
			|| "an unknown version";
		this.OS = this.searchString(this.dataOS) || "an unknown OS";
	},
	searchString: function (data) {
		for (var i=0;i<data.length;i++)	{
			var dataString = data[i].string;
			var dataProp = data[i].prop;
			this.versionSearchString = data[i].versionSearch || data[i].identity;
			if (dataString) {
				if (dataString.indexOf(data[i].subString) != -1)
					return data[i].identity;
			}
			else if (dataProp)
				return data[i].identity;
		}
	},
	searchVersion: function (dataString) {
		var index = dataString.indexOf(this.versionSearchString);
		if (index == -1) return;
		return parseFloat(dataString.substring(index+this.versionSearchString.length+1));
	},
	dataBrowser: [
		{ 	string: navigator.userAgent,
			subString: "OmniWeb",
			versionSearch: "OmniWeb/",
			identity: "OmniWeb"
		},
		{
			string: navigator.vendor,
			subString: "Apple",
			identity: "Safari"
		},
		{
			prop: window.opera,
			identity: "Opera"
		},
		{
			string: navigator.vendor,
			subString: "iCab",
			identity: "iCab"
		},
		{
			string: navigator.vendor,
			subString: "KDE",
			identity: "Konqueror"
		},
		{
			string: navigator.userAgent,
			subString: "Firefox",
			identity: "Firefox"
		},
		{
			string: navigator.vendor,
			subString: "Camino",
			identity: "Camino"
		},
		{		// for newer Netscapes (6+)
			string: navigator.userAgent,
			subString: "Netscape",
			identity: "Netscape"
		},
		{
			string: navigator.userAgent,
			subString: "MSIE",
			identity: "Explorer",
			versionSearch: "MSIE"
		},
		{
			string: navigator.userAgent,
			subString: "Gecko",
			identity: "Mozilla",
			versionSearch: "rv"
		},
		{ 		// for older Netscapes (4-)
			string: navigator.userAgent,
			subString: "Mozilla",
			identity: "Netscape",
			versionSearch: "Mozilla"
		}
	],
	dataOS : [
		{
			string: navigator.platform,
			subString: "Win",
			identity: "Windows"
		},
		{
			string: navigator.platform,
			subString: "Mac",
			identity: "Mac"
		},
		{
			string: navigator.platform,
			subString: "Linux",
			identity: "Linux"
		}
	]

};
BrowserDetect.init();

Element.ELEMENT_NODE = 1;

Element.descendantsWithClassName = function(parentElement, className) {
  var children = parentElement.getElementsByTagName('*');
  return $A(children).inject([], function(elements, child) {
    if (Element.hasClassName(child, className)) {
      elements.push(child);
    }
    return elements;
  });
};

Element.conceal = function(element) {
  element.style.visibility = 'hidden';
};

Element.reveal = function(element) {
  element.style.visibility = 'visible';
};

Element.create = function(name) {
  return document.createElement(name);
};

Element.newTextNode = function(text) {
  return document.createTextNode(text);
};

Element.asHTML = function(el) {
  var bar = Element.create('bar');
  bar.appendChild(el);
  return bar.innerHTML;
};

Element.previousSiblingElement = function(el) {
	var sibling = el.previousSibling;
	while(sibling && sibling.nodeType != Element.ELEMENT_NODE) {
		sibling = sibling.previousSibling;
	}
  return sibling;
};
Element.nextSiblingElement = function(el) {
	var sibling = el.nextSibling;
	while(sibling && sibling.nodeType != Element.ELEMENT_NODE) {
		sibling = sibling.nextSibling;
	}
  return sibling;
};


Element.getPosY = function(element) {
  return YAHOO.util.DragDropMgr.getPosY(element);
};

Element.getPosX = function(element) {
  return YAHOO.util.DragDropMgr.getPosX(element);
};


Element.isElementOverVerticalScrollbar = function(element, scrollableElement) {

  if(scrollableElement.clientHeight >= scrollableElement.scrollHeight) {
    return false;
  }


  var elementPosition = {
    y: Element.getPosY(element),
    x: Element.getPosX(element)
  }
  var scrollableElementPosition = {
    y: Element.getPosY(scrollableElement),
    x: Element.getPosX(scrollableElement)
  }

  var elementRegion = new Region (
      elementPosition.y,
      elementPosition.x + element.clientWidth,
      elementPosition.y + element.clientHeight,
      elementPosition.x);

  var verticalScrollbarRegion = new Region (
      scrollableElementPosition.y,
      scrollableElementPosition.x + scrollableElement.clientWidth,
      scrollableElementPosition.y + scrollableElement.clientHeight,
      scrollableElementPosition.x + scrollableElement.clientWidth - 15);

  return elementRegion.intersects(verticalScrollbarRegion);
}

Element.hideScrollbarsUnderElement = function(element, scrollableElementIds) {
  if(BrowserDetect.OS != "Mac" || 
    (BrowserDetect.browser == "Firefox" && BrowserDetect.version == 3) ||
    (BrowserDetect.browser == "Safari")) {
    return;
  }
  for (var i=0; i<scrollableElementIds.length; i++) {
     var scrollableElement = document.getElementById(scrollableElementIds[i]);
     if(scrollableElement) {
       if(Element.isElementOverHorizontalScrollbar(element, scrollableElement)) {
           Element.addClassName(scrollableElement, "no_xscroll");
       };
       if(Element.isElementOverVerticalScrollbar(element, scrollableElement)) {
           Element.addClassName(scrollableElement, "no_yscroll");
       };
     }
  }
}

Element.unhideScrollbars = function(scrollableElementIds) {
  for (var i=0; i<scrollableElementIds.length; i++) {
    var element = document.getElementById(scrollableElementIds[i]);
    if(element) {
      Element.removeClassName(element, "no_xscroll");
      Element.removeClassName(element, "no_yscroll");
    };
  }
}



Element.isElementOverHorizontalScrollbar = function(element, scrollableElement) {

  if(scrollableElement.clientWidth >= scrollableElement.scrollWidth) {
    return false;
  }

  var elementPosition = {
    y: Element.getPosY(element),
    x: Element.getPosX(element)
  }
  var scrollableElementPosition = {
    y: Element.getPosY(scrollableElement),
    x: Element.getPosX(scrollableElement)
  }

  var elementRegion = new Region (
      elementPosition.y,
      elementPosition.x + element.clientWidth,
      elementPosition.y + element.clientHeight,
      elementPosition.x);

  var horizontalScrollbarRegion = new Region (
      scrollableElementPosition.y + scrollableElement.clientHeight - 15,
      scrollableElementPosition.x + scrollableElement.clientWidth,
      scrollableElementPosition.y + scrollableElement.clientHeight,
      scrollableElementPosition.x);

  return elementRegion.intersects(horizontalScrollbarRegion);
}



/* Strip whitespace from the beginning and end of a string */
if (typeof String.prototype.trim == "undefined") {
    String.prototype.trim = function () {
        return this.replace(/^\s+|\s+$/g,"");
    };
}
/* Count the number of substring occurrences */
if (typeof String.prototype.substrCount == "undefined") {
    String.prototype.substrCount = function (s) {
        return this.split(s).length - 1;
    };
}
String.prototype.isAlpha = function () {
    return (this >= 'a' && this <= 'z\uffff') || (this >= 'A' && this <= 'Z\uffff');
};
String.prototype.isDigit = function () {
    return (this  >= '0' && this  <= '9');
};
String.prototype.htmlEscape = function() {
    var s = this;
    s = s.replace(/&/g, '&amp;');
    s = s.replace(/>/g, '&gt;');
    s = s.replace(/</g, '&lt;');
    s = s.replace(/"/g, '&quot;');
    return s;
};

Array.prototype.contains = function (value) {
  return this.indexOf(value) != -1;
};

Array.prototype.last = function() {
  return this[this.length - 1];
};

Array.prototype.isEmpty = function () {
  return this.length === 0;
};

Array.prototype.collect = function(f) {
  var result = [];
  for (var i = 0; i < this.length; i++) {
    result.push(f(this[i]));
  }
  return result;
};

Array.prototype.detect = function(f) {
  var result = [];
  for (var i = 0; i < this.length; i++) {
    if (f(this[i])) {
      return this[i];
    }
  }
  return null;
};

var Utils = {
	centerInWindow: function(element) {
		this.alignInWindow(element, 0.5, 0.5);
	},

	// Note: dialogs look best aligned at .5,.33
	alignInWindow: function(element, horizontalRatio, verticalRatio) {
		var windowDimensions = Utils.windowDimensions();
    var elementDimensions = Element.getDimensions(element);

		var new_left = (windowDimensions.width - elementDimensions.width)*horizontalRatio + "px";
		var new_top = (windowDimensions.height - elementDimensions.height)*verticalRatio + "px";
    element.style.position='absolute';
    element.style.left = new_left;
		element.style.top = new_top;
	},

	windowDimensions: function() {
		return {
			height: this.window().innerHeight || document.documentElement.clientHeight || document.body.clientHeight,
			width: this.window().innerWidth || document.documentElement.clientWidth || document.body.clientWidth
		};
	},

	useMockWindow: function (w) {
		this.mockedWindow = w;
	},

	window: function() {
		return this.mockedWindow || window;
	},

	redirectTo: function(url) {
		window.location.href = url;
	},

	heightWithBorders: function(elem) {
		return Element.getDimensions(elem).height;
	},

	widthWithBorders: function(elem) {
		return Element.getDimensions(elem).width;
	},

	widthWithBordersAndMargins: function(elem) {
		var width = Element.getDimensions(elem).width;
    width = width + this.styleAsNum(elem, "margin-left");
    width = width + this.styleAsNum(elem, "margin-right");
    return width;
  },

	height: function(elem) {
		return this.heightWithBorders(elem) - this.heightPaddingAndBorders(elem);
	},

  heightPaddingAndBorders: function(elem) {
    var padding = this.styleAsNum(elem, "padding-top");
    padding += this.styleAsNum(elem, "padding-bottom");
    padding += this.styleAsNum(elem, "border-top-width");
    padding += this.styleAsNum(elem, "border-bottom-width");
    return padding;
  },

  width: function(elem) {
		var width = this.widthWithBorders(elem);
		width = width - this.styleAsNum(elem, "padding-left");
		width = width - this.styleAsNum(elem, "padding-right");
		width = width - this.styleAsNum(elem, "border-left-width");
		width = width - this.styleAsNum(elem, "border-right-width");
		return width;
	},

  setWidth: function(elem, pixels) {
    elem.style.width = this._pixelsAsStyleUnit(pixels);
  },

  setHeight: function(elem, pixels) {
    elem.style.height = this._pixelsAsStyleUnit(pixels);
  },

  _pixelsAsStyleUnit: function(pixels) {
    // Note: in IE, NaN != NaN
    if (pixels == NaN || (""+pixels) == "NaN") { pixels = 0;}
    pixels = parseInt(pixels);
    if (pixels < 0) { pixels = 0;}
    return pixels.toString() + "px";
  },

  marginLeft: function(elem) { return this.styleAsNum(elem, "margin-left"); },
  marginRight: function(elem) { return this.styleAsNum(elem, "margin-right"); },
  borderLeft: function(elem) { return this.styleAsNum(elem, "border-left-width"); },
  borderRight: function(elem) { return this.styleAsNum(elem, "border-right-width"); },

  styleAsNum: function(elem, mozillaProp) {
		var computedStyle = Element.getStyle(elem, mozillaProp);
    if (!computedStyle) {
      return 0;
    }

    computedStyle = computedStyle.substr(0, computedStyle.length-2);
    if (isNaN(computedStyle)) {
			return 0;
		}
		return parseInt(computedStyle);
	},

	asString: function(hash) {
		var str = "{";
		for (var key in hash) {
			str = str + key + ":" + hash[key] + ",";
		}
		return str + "}";
	},

	hashEquals: function(hash1, hash2) {
		if (hash1 == null && hash2 == null) {return true;}
		if (hash1 == null || hash2 == null) {return false;}
		for (var key1 in hash1) {
			if (hash2[key1] == null) {return false;}
			if (hash1[key1] != hash2[key1]) {return false;}
		}
		for (var key2 in hash2) {
			if (hash1[key2] == null) {return false;}
		}
		return true;
	},

	debug: function(obj) {
	  var info = [];

	  if(typeof obj in ["string","number"]) {
	    return obj;
	  } else {
	    for (property in obj) {
	      if(typeof obj[property]=="function") {
	        info.push(property + ' => function');
	      } else {
	        info.push(property + ' => ' +
	          (typeof obj[property] == "string" ?
	            '"' + obj[property] + '"' :
	            obj[property]));
        }
      }
    }
	  return ("'" + obj + "' #" + typeof obj +
	    ": {" + info.join(", ") + "}");
	},

	truncatedText: function(origText, maxLength) {
		if (origText == null) {
			return "&nbsp;";
		} else if (origText.length > maxLength) {
			return origText.substr(0, maxLength - 2) + "...";
		} else {
			return origText;
		}
	},

	stripAccents : function(s) {
		var stripped_string = "";
		for(var i = 0; i < s.length; i++) {
			ch = s.charAt(i);
			stripped = Utils.characterMap[ch];
			if (stripped != null) {
				ch = stripped;
			}
			stripped_string += ch;
		}
		return stripped_string;
	}

};

Utils.isIE = (navigator.userAgent.toLowerCase().indexOf("msie") != -1);
Utils.isOpera = (navigator.userAgent.toLowerCase().indexOf("opera") != -1);
Utils.isSafari = (navigator.userAgent.toLowerCase().indexOf("safari") != -1);

Utils.characterMap = {
'\u00c0' : 'A', // ?
'\u00c1' : 'A', // ?
'\u00c2' : 'A', // ?
'\u00c3' : 'A', // ?
'\u00c4' : 'A', // ?
'\u00c5' : 'A', // ?
'\u00c6' : "AE", // ?
'\u00c7' : 'C', // ?
'\u00c8' : 'E', // ?
'\u00c9' : 'E', // ?
'\u00ca' : 'E', // ?
'\u00cb' : 'E', // ?
'\u00cc' : 'I', // ?
'\u00cd' : 'I', // ?
'\u00ce' : 'I', // ?
'\u00cf' : 'I', // ?
//'\u00d0' : 'x', // ?
'\u00d1' : 'N', // ?
'\u00d2' : 'O', // ?
'\u00d3' : 'O', // ?
'\u00d4' : 'O', // ?
'\u00d5' : 'O', // ?
'\u00d6' : 'O', // ?
//'\u00d7' : 'x', // ?
'\u00d8' : 'O', // ?
'\u00d9' : 'U', // ?
'\u00da' : 'U', // ?
'\u00db' : 'U', // ?
'\u00dc' : 'U', // ?
'\u00dd' : 'Y', // ?
//'\u00de' : 'x', // ?
//'\u00df' : 'x', // ?
'\u00e0' : 'a', // ?
'\u00e1' : 'a', // ?
'\u00e2' : 'a', // ?
'\u00e3' : 'a', // ?
'\u00e4' : 'a', // ?
'\u00e5' : 'a', // ?
'\u00e6' : "ae", // ?
'\u00e7' : 'c', // ?
'\u00e8' : 'e', // ?
'\u00e9' : 'e', // ?
'\u00ea' : 'e', // ?
'\u00eb' : 'e', // ?
'\u00ec' : 'i', // ?
'\u00ed' : 'i', // ?
'\u00ee' : 'i', // ?
'\u00ef' : 'i', // ?
//'\u00f0' : 'x', // ?
'\u00f1' : 'n', // ?
'\u00f2' : 'o', // ?
'\u00f3' : 'o', // ?
'\u00f4' : 'o', // ?
'\u00f5' : 'o', // ?
'\u00f6' : 'o', // ?
//'\u00f7' : 'x', // ?
'\u00f8' : 'o', // ?
'\u00f9' : 'u', // ?
'\u00fa' : 'u', // ?
'\u00fb' : 'u', // ?
'\u00fc' : 'u', // ?
'\u00fd' : 'y', // ?
//'\u00fe' : 'x', // ?
'\u00ff' : 'y' // ?
};

Object.overrides = function(descendant, base) {
	for(property in base.prototype) {
		if (undefined == descendant.prototype[property]) {
			descendant.prototype[property] = base.prototype[property];
		} else {
			descendant.prototype["super_" + property] = base.prototype[property];
		}
	}
};

CruftyPopup = Class.create();
CruftyPopup.prototype = {
	initialize: function(_popupElementName, _maskElementName) {
    if( _popupElementName == undefined ) {
      _popupElementName = 'detailPane';
    }
    if( _maskElementName == undefined ) {
      _maskElementName = 'mask';
    }


    this.popupElement = $(_popupElementName);
    if (this.popupElement == null) {
      this.popupElement = document.createElement('div');
      document.body.appendChild(this.popupElement);
      this.popupElement.id = _popupElementName;
      this.popupElement.style.display = "none";
      this.popupElement.style.zindex = "2000";
    }

    this.maskElement = $(_maskElementName);
		if (this.maskElement == null) {
			this.maskElement = document.createElement('div');
			document.body.appendChild(this.maskElement);
			this.maskElement.id = _maskElementName;
			this.maskElement.style.width = "100%";
      this.maskElement.style.height = "100%";
      this.maskElement.style.position = "absolute";
      this.maskElement.style.top = "0px";
      this.maskElement.style.left = "0px";
      this.maskElement.style.opacity = ".50";
      this.maskElement.style.zindex = "1000";
      this.maskElement.style.display = "none";

    }

		this.visible = false;
	},

  maskAndPopup: function() {
    this.mask();
    this.popup();
  },

  maskAndPopupAndCenter: function() {
    this.center();
    this.maskAndPopup();
  },

  mask: function() {
    Element.show(this.maskElement);
  },

  popup: function() {
		Element.show(this.popupElement);
		this.visible = true;
	},

  popupAndCenter: function() {
  	this.popup();
  	this.center();
   },

  center: function() {
    Utils.centerInWindow(this.popupElement);
  },

  hide: function() {
		Element.hide(this.popupElement);
		Element.hide(this.maskElement);
		this.visible = false;
	}
};

/***
 DEPRECATED DEPRECATED DEPRECATED - Use Pivotal.Popup, please!
*/
Popup2 = Class.create();
Popup2.prototype = {
 	initialize: function(popupElementId, options) {
 		this.popupElementId = popupElementId;
 		this.options = {
 			placement: Placement.CENTER_IN_WINDOW,
 			maskOpacity: 0.5,
 			maskElementId: "mask",
 			maskZindex: 1000,
 			maskBackgroundColor: "#FFFFFF",
 			popupZindex: 2000,
 			popupCssClass: "popup",
      scrollableElementIds: []
     };
     Object.extend(this.options, options || {});
     this._initializePopupElement();
 	},

  visible: function() {
    return this.popupElement.visible();
  },

   showPopup: function() {
 		this.options.placement.placeElement(this.popupElement);
    Element.show(this.popupElement);
    Element.hideScrollbarsUnderElement(this.popupElement, this.options.scrollableElementIds);
    Element.reveal(this.popupElement);
  },

  showMask: function() {
		this._initializeMaskElement();
	 	Element.reveal(this.maskElement);
    Element.hideScrollbarsUnderElement(this.maskElement, this.options.scrollableElementIds);
  },

	showPopupWithMask: function() {
		this.showMask();
		this.showPopup();
	},

	hide: function() {
    Element.conceal(this.popupElement);
    Element.hide(this.popupElement);
    if (this.maskElement) {
      Element.conceal(this.maskElement);
    }
    Element.unhideScrollbars(this.options.scrollableElementIds);
  },

 	_initializeMaskElement: function() {
    this.maskElement = $(this.options.maskElementId);
		if (this.maskElement == null) {
      this.maskElement = document.createElement('div');
			document.body.appendChild(this.maskElement);
      document.body.style.height = "100%";
      this.maskElement.id = this.options.maskElementId;
			this.maskElement.style.backgroundColor = this.options.maskBackgroundColor;
			this.maskElement.style.width = "100%";
			this.maskElement.style.height = document.documentElement.scrollHeight + "px";
			this.maskElement.style.position = "absolute";
			this.maskElement.style.top = "0px";
			this.maskElement.style.left = "0px";
			Element.setOpacity(this.maskElement, this.options.maskOpacity);
			this.maskElement.style.zIndex = this.options.maskZindex.toString();
			Element.conceal(this.maskElement);
	 	}
 	},

 	_initializePopupElement: function() {
 		this.popupElement = $(this.popupElementId);
 		if (this.popupElement == null) {
			this.popupElement = document.createElement('div');
			document.body.appendChild(this.popupElement);
			this.popupElement.id = this.popupElementId;
 		}
    this.popupElement.className = this.options.popupCssClass;
    this.popupElement.style.zIndex = this.options.popupZindex.toString();
    Element.hide(this.popupElement);
    Element.conceal(this.popupElement);
 	}
};

/***
 DEPRECATED DEPRECATED DEPRECATED - Use Pivotal.Popup, please!
*/
Placement = Class.create();
Placement.prototype = {

	initialize: function(positionCode, options) {
		this.positionCode = positionCode;
		this.options = {
            spacingPixels: 5,
            align: Placement.ALIGN_LEFT_EDGE,
            offsetHorizontal: 0,
            offsetVertical: 0
        };
		Object.extend(this.options, options || {});
	},

	placeElement: function(element) {
		switch (this.positionCode) {
			case Placement.CENTER_CODE:
				Utils.centerInWindow(element);
				break;
			case Placement.DO_NOT_POSITION_CODE:
				break;
			case Placement.BELOW_CODE:
				var relatedElement = $(this.options.relatedElementId);
				var relatedOffset = this.getOffsetFor(relatedElement);
				var relatedHeight = Utils.heightWithBorders(relatedElement);
                element.style.position = "absolute";
                switch (this.options.align) {
                  case Placement.ALIGN_LEFT_EDGE:
                    element.style.left = (relatedOffset[0] + this.options.offsetHorizontal) + "px";
                    break;
                  case Placement.ALIGN_RIGHT_EDGE:
                    var relatedWidth = Utils.widthWithBorders(relatedElement);
                    var elementWidth = Utils.widthWithBorders(element);
                    element.style.left = (relatedOffset[0] + relatedWidth - elementWidth + this.options.offsetHorizontal) + "px";
                    break;
                  default:
                    throw new Error("Unknown alignment - " + this.options.align);
                }
                element.style.top = (relatedOffset[1] + relatedHeight + this.options.offsetVertical + this.options.spacingPixels) + "px";
                break;
            default:
                throw new Error("Unknown position code - " + this.positionCode);
        }
    },

    //TODO(edward): In Tracker, we have scrollbars and Position.cumulativeOffset doesn't seem to respect them.
    //I broke this out into a function pending discussion so that I could switch out its implementation with
    //YAHOO.util.Dom.getXY in Tracker, without making everyone who uses Popup2 need to pull in Yahoo.
    getOffsetFor: function(element) {
        return Position.cumulativeOffset(element);
    }
};
Placement.CENTER_CODE = "center";
Placement.DO_NOT_POSITION_CODE = "noposition";
Placement.BELOW_CODE = "below";
Placement.ALIGN_LEFT_EDGE = "leftedge";
Placement.ALIGN_RIGHT_EDGE = "rightedge";
Placement.CENTER_IN_WINDOW = new Placement(Placement.CENTER_CODE);
Placement.DO_NOT_POSITION = new Placement(Placement.DO_NOT_POSITION_CODE);
Placement.belowElement = function(elementId, options) {
  options.relatedElementId = elementId;
  return new Placement(Placement.BELOW_CODE, options);
}

PopupWindow = Class.create();
PopupWindow.prototype = {
	initialize: function(url) {
		this.super_initialize();
    this.mask();
    new Ajax.Updater(this.popupElement, url, {
			asynchronous:true,
			evalScripts:true,
			method:'get',
			onComplete:this.popupAndCenter.bind(this)
		});
	}
};
Object.overrides(PopupWindow, CruftyPopup);

Confirm = Class.create();
Confirm.prototype = {
	initialize: function(text, onComplete) {
		this.onComplete = onComplete;
		this.super_initialize();
    this.mask();

    this.popupElement.innerHTML = "";
		var popupTemplate = $('popup_window_template').cloneNode(true);
		Element.show(popupTemplate);
		this.popupElement.appendChild(popupTemplate);

		this.setHeader('confirm');
		this.setContents(text);
		this.confirmButton = this.createButton("/images/b_delete.png", this.clickConfirm.bind(this));
		this.cancelButton = this.createButton("/images/b_cancel.png", this.hide.bind(this));
		this.addButton(this.confirmButton);
		this.addButton(this.cancelButton);

		this.popup();
    this.center();
  },

	setHeader: function(headerText) {
		this.popupHeaderElement = Element.descendantsWithClassName(this.popupElement, 'module_box_title')[0];
		this.popupHeaderElement.innerHTML = headerText;
	},

	setContents: function(contents) {
		this.popupContentsElement = Element.descendantsWithClassName(this.popupElement, 'module_box_contents')[0];
		this.popupContentsElement.innerHTML = contents;
	},

	addButton: function(button) {
		if (this.buttonAreaElement == null) {
			this.buttonAreaElement = document.createElement("div");
			this.buttonAreaElement.className = 'button_area';
			this.popupContentsElement.appendChild(this.buttonAreaElement);
		} else {
			this.buttonAreaElement.appendChild(document.createTextNode(' '));
		}
		this.buttonAreaElement.appendChild(button);
	},

	createButton: function(buttonSrc, buttonFunction) {
		var button = document.createElement("a");
		button.innerHTML = "<img src='" + buttonSrc + "' />";
		button.onclick = buttonFunction;
		return button;
	},

	clickConfirm: function() {
		this.hide();
		this.onComplete();
	}
};
Object.overrides(Confirm, CruftyPopup);


DateUtils = {
  SUNDAY: 0,
  MONDAY: 1,
  TUESDAY: 2,
  WEDNESDAY: 3,
  THURSDAY: 4,
  FRIDAY: 5,
  SATURDAY: 6,

  systemTime: null,

  now: function() {
    if (this.systemTime!=null) {
      return this.systemTime;
    } else {
      return new Date();
    }
  },

  setTime: function(date) {
    this.systemTime = date;
  },

  previousMonday: function(fromDate) {
    var date = fromDate ? new Date(fromDate) : DateUtils.now();
    var dayOfWeek = date.getDay();
    if (dayOfWeek == DateUtils.SUNDAY) { dayOfWeek = 7; }
    var rightDayWrongTime = new Date(date - DateUtils.days(dayOfWeek - 1));
    var monday = rightDayWrongTime.atMidnight();
    if (monday.getDay() != 1) {
      throw "Monday isn't Monday";
    }
    return monday;
  },

  // TODO: rename me to something that describes what I do.
  weeks: function(numberOfWeeks) {
    return numberOfWeeks * DateUtils.days(7);
  },

  days: function(numberOfDays) {
    // returns msecs in numberOfDays
    return numberOfDays * 60*60*24*1000;
  }
};

//todo: test
Date.prototype.previousMonday = function() {
  return DateUtils.previousMonday(this);
};

Date.prototype.beginningOfWeekWithStartDay = function(weekStartDay) {
  var daysAgo;
  if (weekStartDay <= this.getDay()) {
    daysAgo = this.getDay() - weekStartDay;
  } else {
    daysAgo = 7-(weekStartDay - this.getDay());
  }
  return this.plusDays(0 - daysAgo).atMidnight();
};

Date.prototype.atMidnight = function() {
  return new Date(this.getFullYear(), this.getMonth(), this.getDate());
}

Date.prototype.elapsedDaysFrom = function(anotherDate) {
	//add one hour to time between dates to handle DST changes
	var timeDifference = this.getTime() - anotherDate.getTime();
  return Math.floor(( timeDifference + 3600000) / DateUtils.days(1));
};

Date.prototype.isBetween = function(start, finish) {
  if (finish < start) {
    var x = start;
    start = finish;
    finish = x;
  }
  if (this < start) {return false;}
  if (start < finish && this >= finish) {return false;}
  return true;
};

Date.prototype.plusMsec = function(msec) {
  return new Date(this.getTime() + msec);
};

Date.prototype.plusHours = function(hours) {
  return new Date(this.getTime() + (hours * 60 * 60 * 1000));
};

Date.prototype.plusDays = function(days) {
  var newDate = new Date(this.getTime());
  newDate.setDate(newDate.getDate()+days);
  return newDate;
};

Date.prototype.plusWeeks = function(numWeeks) {
  return this.plusDays(7 * numWeeks);
};

Date.prototype.minusWeeks = function(numWeeks) {
  return this.plusDays(-(7 * numWeeks));
};

Date.equals = function(a, b) {
  return (
        (a == null && b == null)
    ||  (a != null && b != null && a.getTime() == b.getTime())
  );
}
Date.equalsMDYYYY = function(a, b) {
  return (
        (a == null && b == null)
    ||  (a != null && b != null && a.toMDYYYY() == b.toMDYYYY())
  );
}
Date.prototype.toMDYYYY = function() {
  var date_str = this.getMonth()+1;
  date_str += '/' + this.getDate();  // "date" is day :-P
  date_str += '/' + this.getFullYear();
  return date_str;
}

Date.prototype.isBefore = function(otherDate) {
  return this.getTime()<otherDate.getTime();
}


Region = Class.create();
Region.prototype = {
	initialize: function(top, right, bottom, left) {
		this.top = top;
    this.right = right;
    this.bottom = bottom;
    this.left = left;
  }
}

Region.prototype.intersects = function(anotherRectangle) {
  var verticalOverlap = false;
  var horizontalOverlap = false;

  if(this.top <= anotherRectangle.top && this.bottom >= anotherRectangle.bottom) {
    verticalOverlap = true;
  }
  if(this.top >= anotherRectangle.top && this.top <= anotherRectangle.bottom) {
    verticalOverlap = true;
  }
  if(this.bottom >= anotherRectangle.top && this.bottom <= anotherRectangle.bottom) {
    verticalOverlap = true;
  }

  if(this.left <= anotherRectangle.left && this.right >= anotherRectangle.right) {
    horizontalOverlap = true;
  }
  if(this.left >= anotherRectangle.left && this.left <= anotherRectangle.right) {
    horizontalOverlap = true;
  }
  if(this.right >= anotherRectangle.left && this.right <= anotherRectangle.right) {
    horizontalOverlap = true;
  }

  return verticalOverlap && horizontalOverlap;
}


// This function returns the name of a given function. It does this by
// converting the function to a string, then using a regular expression
// to extract the function name from the resulting code.
function funcname(f) {
    var s = f.toString().match(/function (\w*)/)[1];
    if ((s == null) || (s.length == 0)) return "anonymous";
    return s;
}

// This function returns a string that contains a "stack trace."
function stacktrace() {
    var s = "";  // This is the string we'll return.
    // Loop through the stack of functions, using the caller property of
    // one arguments object to refer to the next arguments object on the
    // stack.
    for(var a = arguments.caller; a != null; a = a.caller) {
        // Add the name of the current function to the return value.
        s += funcname(a.callee) + "\n";

        // Because of a bug in Navigator 4.0, we need this line to break.
        // a.caller will equal a rather than null when we reach the end
        // of the stack. The following line works around this.
        if (a.caller == a) break;
    }
    return s;
}

function rand(max) {
  return Math.floor(Math.random() * ( max ));
}

function shuffle(myArray) {
  var i = myArray.length;
  if (i == 0) {return false;}
  while (--i) {
    var j = rand(i + 1);
    var tempi = myArray[i];
    var tempj = myArray[j];
    myArray[i] = tempj;
    myArray[j] = tempi;
  }
}

// From http://wiki.script.aculo.us/scriptaculous/show/Cookie
var Cookie = {
  set: function(name, value, daysToExpire) {
    var expire = '';
    if(!daysToExpire) daysToExpire = 365;
    var d = new Date();
    d.setTime(d.getTime() + (86400000 * parseFloat(daysToExpire)));
    expire = 'expires=' + d.toGMTString();
    var path = "path=/"
    var cookieValue = escape(name) + '=' + escape(value || '') + '; ' + path + '; ' + expire + ';';
    return document.cookie = cookieValue;
  },
  get: function(name) {
    var cookie = document.cookie.match(new RegExp('(^|;)\\s*' + escape(name) + '=([^;\\s]+)'));
    return (cookie ? unescape(cookie[2]) : null);
  },
  erase: function(name) {
    var cookie = Cookie.get(name) || true;
    Cookie.set(name, '', -1);
    return cookie;
  },
  eraseAll: function() {
    // Get cookie string and separate into individual cookie phrases:
    var cookieString = "" + document.cookie;
    var cookieArray = cookieString.split("; ");

    // Try to delete each cookie:
    for(var i = 0; i < cookieArray.length; ++ i)
    {
      var singleCookie = cookieArray[i].split("=");
      if(singleCookie.length != 2)
        continue;
      var name = unescape(singleCookie[0]);
      Cookie.erase(name);
    }
  },
  accept: function() {
    if (typeof navigator.cookieEnabled == 'boolean') {
      return navigator.cookieEnabled;
    }
    Cookie.set('_test', '1');
    return (Cookie.erase('_test') === '1');
  },
  exists: function(cookieName) {
    var cookieValue = Cookie.get(cookieName);
    if(!cookieValue) return false;
    return cookieValue.toString() != "";
  }
};

function asCgiString(hash, model) {
  var pairs = [];
	for (var key in hash) {
    var name;
    if (model) {
      name = model + "[" + key + "]";
    } else {
      name = key;
    }
    pairs[pairs.length] = name + "=" + encodeURIComponent(hash[key]);
  }
  return pairs.join("&");
};

function fromCgiString(cgiString) {
  var hash = {};
  var pairs = cgiString.split("&");
  for (var i=0; i<pairs.length; ++i) {
    var stuff = pairs[i].split("=");
    hash[stuff[0]] = decodeURIComponent(stuff[1]);
  }
  return hash;
}

function formToCgiHash(form) {
  var params = {};
  $A(form.elements).each(function(inputItem) {
    if (inputItem.type == "submit" || inputItem.type == "button") {
      return;
    }
    if (inputItem.type == 'checkbox' || inputItem.type == 'radio') {
      if (inputItem.checked) {
        if (params[inputItem.name]) {
          throw 'Multiple checkboxes/radio buttons with the same name are not supported!';
        }
        params[inputItem.name] = inputItem.value;
      }
    }
    else {
      params[inputItem.name] = inputItem.value;
    }
  });
  return params;
}

function addJavaScriptToHead(src) {
  var e = document.createElement("script");
  e.type = "text/javascript";
  e.src = src;
  document.getElementsByTagName("head")[0].appendChild(e);
}
