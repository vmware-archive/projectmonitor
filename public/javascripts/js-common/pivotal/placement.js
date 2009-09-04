Pivotal.Placement = Class.create();
Pivotal.Placement.prototype = {

	initialize: function(positionCode, options) {
		this.positionCode = positionCode;
		this.options = {
            spacingPixels: 5,
            align: Pivotal.Placement.ALIGN_LEFT_EDGE,
            offsetHorizontal: 0,
            offsetVertical: 0
        };
		Object.extend(this.options, options || {});
	},

	placeElement: function(element) {
		switch (this.positionCode) {
			case Pivotal.Placement.CENTER_CODE:
				Utils.centerInWindow(element);
				break;
			case Pivotal.Placement.DO_NOT_POSITION_CODE:
				break;
			case Pivotal.Placement.BELOW_CODE:
 				var relatedElement = $(this.options.relatedElementId);
				var relatedOffset = this.getOffsetFor(relatedElement);
				var relatedHeight = Utils.heightWithBorders(relatedElement);
        var relatedWidth = Utils.widthWithBorders(relatedElement);
        var elementWidth = Utils.widthWithBorders(element);
        element.style.position = "absolute";
        var leftAlignX = (relatedOffset[0] + this.options.offsetHorizontal);
        var rightAlignX = (relatedOffset[0] + relatedWidth - elementWidth + this.options.offsetHorizontal);

        switch (this.options.align) {
          case Pivotal.Placement.ALIGN_LEFT_EDGE:
            element.style.left = leftAlignX + "px";
            break;
          case Pivotal.Placement.ALIGN_RIGHT_EDGE:
            element.style.left = (rightAlignX < 0 ? leftAlignX : rightAlignX) + "px";
            break;
          default:
            throw new Error("Unknown alignment - " + this.options.align);
        }
        element.style.top = (relatedOffset[1] + relatedHeight + this.options.offsetVertical + this.options.spacingPixels) + "px";
        break;

      case Pivotal.Placement.TO_RIGHT_OF_CODE:
        var relatedElement = $(this.options.relatedElementId);
        var relatedOffset = this.getOffsetFor(relatedElement);
        var relatedHeight = Utils.heightWithBorders(relatedElement);
        var relatedWidth = Utils.widthWithBorders(relatedElement);
        var elementWidth = Utils.widthWithBorders(element);
        element.style.position = "absolute";
        var leftAlignX = (relatedOffset[0] + relatedWidth + this.options.offsetHorizontal);
        var rightAlignX = (relatedOffset[0] + relatedWidth - elementWidth + this.options.offsetHorizontal);
        switch (this.options.align) {
          case Pivotal.Placement.ALIGN_LEFT_EDGE:
            element.style.left = leftAlignX + "px";
            break;
          case Pivotal.Placement.ALIGN_RIGHT_EDGE:
            element.style.left = (rightAlignX < 0 ? leftAlignX : rightAlignX) + "px";
            break;
          default:
            throw new Error("Unknown alignment - " + this.options.align);
        }
        element.style.top = (relatedOffset[1] + this.options.offsetVertical + this.options.spacingPixels) + "px";
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
Pivotal.Placement.CENTER_CODE = "center";
Pivotal.Placement.DO_NOT_POSITION_CODE = "noposition";
Pivotal.Placement.BELOW_CODE = "below";
Pivotal.Placement.ALIGN_LEFT_EDGE = "leftedge";
Pivotal.Placement.ALIGN_RIGHT_EDGE = "rightedge";
Pivotal.Placement.CENTER_IN_WINDOW = new Pivotal.Placement(Pivotal.Placement.CENTER_CODE);
Pivotal.Placement.DO_NOT_POSITION = new Pivotal.Placement(Pivotal.Placement.DO_NOT_POSITION_CODE);
Pivotal.Placement.belowElement = function(elementId, options) {
  options.relatedElementId = elementId;
  return new Pivotal.Placement(Pivotal.Placement.BELOW_CODE, options);
}
Pivotal.Placement.toRightOfElement = function(elementId, options) {
  options.relatedElementId = elementId;
  return new Pivotal.Placement(Pivotal.Placement.TO_RIGHT_OF_CODE, options);
}
