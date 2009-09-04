Pivotal.Popup = Class.create();
Pivotal.Popup.prototype = {
 	initialize: function(popupElementId, options) {
 		this.popupElementId = popupElementId;
 		this.options = {
 			placement: Pivotal.Placement.CENTER_IN_WINDOW,
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
