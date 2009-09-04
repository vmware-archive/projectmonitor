Pivotal.RoundyCorners = {
  create: function(containedElement, cornerSpecification) {
    var theWholeEnchilada = document.createElement('table');
    var body = document.createElement("tbody");
    if (cornerSpecification.className) theWholeEnchilada.className = cornerSpecification.className
    theWholeEnchilada.id = containedElement.id + '_roundy';
    theWholeEnchilada.appendChild(body);
    theWholeEnchilada.cellPadding = 0;
    theWholeEnchilada.cellSpacing = 0;

    var topRow = document.createElement('tr');
    var topLeft = this._buildCornerTd(cornerSpecification.topLeft);
    var topMiddle = this._buildMiddleTd({
      image: cornerSpecification.topMiddle,
      repeat: "repeat-x",
      color: cornerSpecification.color,
      border: cornerSpecification.border,
      onClick: cornerSpecification.onClick,
      side: "Top"
    });
    var topRight = this._buildCornerTd(cornerSpecification.topRight);

    topRow.appendChild(topLeft);
    topRow.appendChild(topMiddle);
    topRow.appendChild(topRight);

    var middleRow = document.createElement('tr');
    var middleLeft = this._buildMiddleTd({
      image: cornerSpecification.middleLeft,
      repeat: "repeat-y",
      color: cornerSpecification.color,
      border: cornerSpecification.border,
      side: "Left"
    });
    var middleMiddle = this._buildMiddleTd({image: cornerSpecification.middleMiddle, repeat: "repeat", color: cornerSpecification.color});
    middleMiddle.appendChild(containedElement);
    if (cornerSpecification.expandToFit) {
      middleMiddle.style.width = "100%";
    }

    var middleRight = this._buildMiddleTd({
      image: cornerSpecification.middleRight,
      repeat: "repeat-y",
      color: cornerSpecification.color,
      border: cornerSpecification.border,
      side: "Right"
    });

    middleRow.appendChild(middleLeft);
    middleRow.appendChild(middleMiddle);
    middleRow.appendChild(middleRight);

    var bottomRow = document.createElement('tr');
    var bottomLeft = this._buildCornerTd(cornerSpecification.bottomLeft);
    var bottomMiddle = this._buildMiddleTd({
      image: cornerSpecification.bottomMiddle,
      repeat: "repeat-x",
      color: cornerSpecification.color,
      border: cornerSpecification.border,
      side: "Bottom"
    });
    var bottomRight = this._buildCornerTd(cornerSpecification.bottomRight);

    bottomRow.appendChild(bottomLeft);
    bottomRow.appendChild(bottomMiddle);
    bottomRow.appendChild(bottomRight);

    body.appendChild(topRow);
    body.appendChild(middleRow);
    body.appendChild(bottomRow);
    return theWholeEnchilada;
  },

  _buildCornerTd: function(imgSrc) {
    var td = document.createElement('td');
    var img = document.createElement("img");
    img.style.display = "block";
    if (imgSrc.indexOf("png") > -1 && document.all) {
      img.src = "/images/blank.gif";
      img.style.filter = 'progid:DXImageTransform.Microsoft.AlphaImageLoader(src=' + imgSrc + ',enabled=1)';
    } else {
      img.src = imgSrc;
    }
    td.appendChild(img);
    return td;
  },

  _buildMiddleTd: function(instructions) {
    var td = document.createElement('td');
    if (instructions.image) {
      td.style.backgroundImage = 'url(' + instructions.image + ')';
      if (instructions.repeat) td.style.backgroundRepeat = instructions.repeat;
    } else if (instructions.color) {
      td.style.backgroundColor = instructions.color;
      if (instructions.border && instructions.side) {
        td.style["border" + instructions.side] = instructions.border;
        td.innerHTML = "&nbsp;";
        td.style.lineHeight = "1px";
      }
    }
    return td;
  },

  wrapExistingElement: function(id, cornerSpecification, displayWhenDone) {
    var element = document.getElementById(id);
    var parent = element.parentNode;
    var children = parent.childNodes;
    var sibling;

    for (var i=0; i<children.length; ++i) {
      if (children[i] == element && i < children.length - 1) {
        sibling = children[i + 1];
        break;
      }
    }

    parent.removeChild(element);
    if (sibling) {
      parent.insertBefore(this.create(element, cornerSpecification), sibling);
    } else {
      parent.appendChild(this.create(element, cornerSpecification));
    }
    if (displayWhenDone) Element.show(id);
  },

  wrapExistingElementsOfClass: function(container, className, cornerSpecification, displayWhenDone) {
    var elements = U.findClassNamesInElement(container, className);
    for (var i=0; i<elements.length; ++i) {
      var tempId = "wrapExistingElementOfClass" + i;
      if (!elements[i].id) elements[i].id = tempId;
      this.wrapExistingElement(elements[i].id, cornerSpecification, displayWhenDone);
      if (elements[i].id == tempId) elements[i].id = "";
    }
  }

};
