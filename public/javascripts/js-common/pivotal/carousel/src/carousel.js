var Pivotal = Pivotal || { }
Pivotal.Carousel = Class.create((function() {
  // Helper to add/remove "disabled" class name from links as needed
  var manageLinkStatus = function(carousel) {
    if (carousel.currentIndex == carousel.maxIndex)  { carousel.nextLink.addClassName('disabled'); }
    if (carousel.currentIndex < carousel.maxIndex)   { carousel.nextLink.removeClassName('disabled'); }
    if (carousel.currentIndex == 0) { carousel.previousLink.addClassName('disabled'); }
    if (carousel.currentIndex > 0)  { carousel.previousLink.removeClassName('disabled'); }
  }
  
  // Stops an event then calls handler
  var handleEvent = function(method, event) {
    event.stop();
    this[method]();
  }
  
  // Scales an element to center dimentions 
  var morphToCenter = function(element) {
    return new Effect.Morph(element, {
      style: { height: this.centerHeight, width: this.centerWidth, marginTop: '0px' },
      sync: true
    });
  }
  
  // Scales an element to mid dimensions
  var morphToMid = function(element) {
    return new Effect.Morph(element, {
      style: { height: this.midHeight, width: this.midWidth, marginTop: this.midMargin },
      sync: true
    });
  }
  
  // Scales an element to normal item dimensions
  var morphToNormal = function(element) {
    return new Effect.Morph(element, {
      style: { height: this.itemHeight, width: this.itemWidth, marginTop: this.itemMargin },
      sync: true
    });
  }
  
  // Scrolls carousel to containerOffset
  var scrollToOffset = function(element) {
    return new Effect.Morph(this.wrapper, {
      style: 'margin-left: -' + this.containerOffset() + 'px',
      duration: 0.5,
      transition: this.transition
    });
  }
  
  // Returning the klass object
  return {
    // How many items should be visible at once. This actually shouldn't be changed.
    windowSize: 5,
    
    // How much bigger the center elements should be
    centerScale: 2,
    
    // How much bigger the mid-elements should be
    midScale: 1.4,
    
    // Default item dimensions
    itemHeight: '50px',
    itemWidth: '75px',

    // Default duration for scrolling
    duration: .5,
    
    // Should the carousel scale
    shouldScale: true,
    
    // Default transition to use (falls back to linear)
    transition: (Effect.Transitions.easeFromTo || Prototype.K),

    initialize: function(element, options) {
      options = options || { };
      Object.extend(this, options);
      this.element = $(element);
      this.currentIndex = 0;
      this.calculateDimensions();
      this.findElements();
      this.setupItems();
      this.setupBehaviors();
      this.adjustContainerWidth();
    },
    
    // Finds proper dimensions for scaled items based on midScale and centerScale options
    calculateDimensions: function() {
      if (this.shouldScale) {
        var itemHeight = parseInt(this.itemHeight);
        var itemWidth = parseInt(this.itemWidth);

        this.centerWidth = itemWidth * this.centerScale + 'px';
        this.centerHeight = itemHeight * this.centerScale + 'px';

        this.midWidth = itemWidth * this.midScale + 'px';
        this.midHeight = itemHeight * this.midScale + 'px';
        this.midMargin = (parseInt(this.centerHeight) - parseInt(this.midHeight)) / 2 + 'px';

        this.itemMargin = (parseInt(this.centerHeight) - parseInt(this.itemHeight)) / 2 + 'px';
      } else {
        this.itemWidth = this.element.down('.container .wrapper > *').getWidth() + 'px';
      }
    },
    
    // Get carousel items, initialize wrapper style
    findElements: function() {
      this.items = this.element.select('.container .wrapper > div');
      this.nextLink = this.element.down('a[href=#next]');
      this.previousLink = this.element.down('a[href=#previous]');
      this.container = this.element.down('.container');
      this.wrapper = this.container.down('.wrapper');
      this.wrapper.setStyle('margin-left: 0px;');
    },
  
    // Sets default styles for items
    setupItems: function() {
      var e;
      this.maxIndex = this.items.length - this.windowSize;
      if (this.shouldScale) this.maxIndex -= 1;
      this.items.invoke('setStyle', { width: this.itemWidth, height: this.itemHeight, marginTop: this.itemMargin });
      if (this.shouldScale) {
        var activeSet = this.activeSet();
        if (e = activeSet[1]) e.setStyle({ width: this.midWidth, height: this.midHeight, marginTop: this.midMargin });
        if (e = activeSet[3]) e.setStyle({ width: this.midWidth, height: this.midHeight, marginTop: this.midMargin });
        if (e = activeSet[2]) e.setStyle({ width: this.centerWidth, height: this.centerHeight, marginTop: '0px' });
      }
    },
    
    // Assigns DOM event handlers
    setupBehaviors: function() {
      this.nextLink.observe('click', handleEvent.bind(this, 'next'));
      this.previousLink.observe('click', handleEvent.bind(this, 'previous'));
    },
    
    // Sets container width based on item dimensions
    adjustContainerWidth: function() {
      var items = this.activeSet();
      var margin = parseInt(items[0].getStyle('margin-right'));
      if (this.shouldScale) {
        var width = (2 * parseInt(this.itemWidth)) +
                    (2 * parseInt(this.midWidth)) +
                    (items.length-1) * margin +
                    parseInt(this.centerWidth)
      } else {
        var width = items.invoke('getWidth').inject(0, function(sum, i) { return sum + i; });
        width += parseInt(items[items.length-1].getStyle('margin-right')) * this.windowSize;
      }
      this.container.setStyle('width: ' + width + 'px');
    },
    
    // Advance carousel
    next: function() {
      if (this.currentIndex == this.maxIndex) { return; }
      this.currentIndex += 1;
      this.redraw();
      if (this.shouldScale) this.scale(-1);
      manageLinkStatus(this);
    },

    // Go backwards
    previous: function() {
      if (this.currentIndex == 0) { return; }
      this.currentIndex -= 1;
      this.redraw();
      if (this.shouldScale) this.scale(1);
      manageLinkStatus(this);
    },
    
    // Returns currently visible items
    activeSet: function() {
      var set = new Array;
      var addToSet = function(i) { set.push(this.items[this.currentIndex + i]); }.bind(this);
      this.windowSize.times(addToSet);
      return set;
    },
    
    // Determines offset for making active set visible
    containerOffset: function() {
      var margin = parseInt(this.items[0].getStyle('margin-right'));
      return this.currentIndex * (parseInt(this.itemWidth) + margin);
    },
    
    // Scrolls to show a new active set
    redraw: function() {
      scrollToOffset.call(this, this.wrapper);
    },
    
    // Scales element sizes for "carousel effect"
    scale: function(i, options) {
      options = options || { };
      options.transition = this.transition;
      options.duration = options.duration || this.duration;

      var activeSet = this.activeSet();
      var newCenter = activeSet[2];
      var oldCenter = activeSet[2+i];
      var growToMid = activeSet[2-i];
      var shrinkToNormal = activeSet[2+2*i];
      
      new Effect.Parallel([
        morphToCenter.call(this, newCenter),
        morphToMid.call(this, oldCenter),
        morphToMid.call(this, growToMid),
        morphToNormal.call(this, shrinkToNormal)
      ], options);
    }
  }
})());
