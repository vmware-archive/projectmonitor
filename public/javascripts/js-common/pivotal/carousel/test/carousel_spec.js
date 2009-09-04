Screw.Unit(function() {
  describe("Carousel", function() {
    var NEXT_LINK = $$('a[href=#next]')[0];
    var PREV_LINK = $$('a[href=#previous]')[0];
    
    before(function() {
      TH.Mock.reset();
      this.carousel = createCarousel();
    });
    
    it("is instance of Pivotal.Carousel", function() {
      expect(this.carousel.constructor).to(equal, Pivotal.Carousel);
      expect(this.carousel.element).to(be_same_element, $('horizontal-carousel'));
    });
    
    it("gets items", function() {
      expect(this.carousel.items).to(have_length, 12);
      $A(this.carousel.items).each(function(element) {
        expect(jQuery(element)).to(match_selector, '#horizontal-carousel .container .wrapper > div');
      }.bind(this));
      expect(this.carousel.nextLink).to(be_same_element, NEXT_LINK)
      expect(this.carousel.previousLink).to(be_same_element, PREV_LINK)
    });
    
    describe("defaults", function() {
      it("uses easeFromTo transition by default", function() {
        expect(this.carousel.transition).to(equal, Effect.Transitions.easeFromTo);
      });
      
      it("sets default duration to .5", function() {
        expect(this.carousel.duration).to(equal, .5);
      });
      
      it("can be overridden for transition", function() {
        var car = new Pivotal.Carousel("horizontal-carousel", { transition: Prototype.K });
        expect(car.transition).to(equal, Prototype.K);
      });
      
      it("can be overridden for duration", function() {
        var car = new Pivotal.Carousel("horizontal-carousel", { duration: 1 });
        expect(car.duration).to(equal, 1);
      });
      
      it("can be overridden for item dimensions", function() {
        var car = new Pivotal.Carousel("horizontal-carousel", {
          itemWidth: '100000px',
          itemHeight: '50999px'
        });
        expect(car.itemWidth).to(equal, '100000px');
        expect(car.itemHeight).to(equal, '50999px');
      })
    });
    
    describe("currentIndex", function() {
      it("defaults to 0", function() {
        expect(this.carousel.currentIndex).to(equal, 0);
      });
      
      it("does not overflow", function() {
        this.carousel.currentIndex = 6;
        this.carousel.next();
        expect(this.carousel.currentIndex).to(equal, 6);
      });
      
      it("does not underflow", function() {
        this.carousel.currentIndex = 0;
        this.carousel.previous();
        expect(this.carousel.currentIndex).to(equal, 0);
      });
      
      it("increments when next() is called", function() {
        this.carousel.next();
        expect(this.carousel.currentIndex).to(equal, 1);
        this.carousel.next();
        expect(this.carousel.currentIndex).to(equal, 2);
      });
      
      it("decrements when previous() is called", function() {
        this.carousel.currentIndex = 6;
        this.carousel.previous();
        expect(this.carousel.currentIndex).to(equal, 5);
        this.carousel.previous();
        expect(this.carousel.currentIndex).to(equal, 4);
      });
    })
    
    describe("next/previous links", function() {
      it("next link calls next()", function() {
        this.called = false;
        this.carousel.next = function() { this.called = true; }.bind(this);
        NEXT_LINK.simulate('click');
        expect(this.called).to(be_true);
      });
      
      it("previous link calls previous()", function() {
        this.called = false;
        this.carousel.previous = function() { this.called = true; }.bind(this);
        PREV_LINK.simulate('click');
        expect(this.called).to(be_true);
      });
      
      it('adds "disabled" class name to next link', function() {
        expect(NEXT_LINK).to_not(have_class_name, 'disabled');
        this.carousel.currentIndex = 5;
        this.carousel.next();
        expect(NEXT_LINK).to(have_class_name, 'disabled');
      })
      
      it('removes "disabled" class name from next link', function() {
        NEXT_LINK.addClassName('disabled');
        this.carousel.currentIndex = 6;
        this.carousel.previous();
        expect(NEXT_LINK).to_not(have_class_name, 'disabled');
      });
      
      it('adds "disabled" class name to previous link', function() {
        expect(PREV_LINK).to_not(have_class_name, 'disabled');
        this.carousel.currentIndex = 1;
        this.carousel.previous();
        expect(PREV_LINK).to(have_class_name, 'disabled');
      })
      
      it('removes "disabled" class name from previous link', function() {
        PREV_LINK.addClassName('disabled');
        this.carousel.next();
        expect(PREV_LINK).to_not(have_class_name, 'disabled');
      });
      
      it("call redraw() method", function() {
        this.called = 0;
        this.carousel.redraw = function() { this.called += 1; }.bind(this);
        this.carousel.next();
        this.carousel.previous();
        expect(this.called).to(equal, 2);
      });
      
      it("call scale() method", function() {
        this.called = 0;
        this.carousel.scale = function() { this.called += 1; }.bind(this);
        this.carousel.next();
        this.carousel.previous();
        expect(this.called).to(equal, 2);
      });
    });
    
    describe("activeSet", function() {
      it("gets active set", function() {
        var items = $$('#horizontal-carousel .container .wrapper > div');
        items.length = 5; // Truncate!
        
        expect(this.carousel.activeSet()).to(have_same_elements, items);
        
        this.carousel.next();
        
        var items = $$('#horizontal-carousel .container .wrapper > div');
        items.shift();
        items.length = 5; // Truncate!
        
        expect(this.carousel.activeSet()).to(have_same_elements, items);
      });
    });
    
    describe("container", function() {
      it("adjusts container width", function() {
        var items = this.carousel.activeSet();
        var margin = parseInt(items[0].getStyle('margin-right'));
        var width = (2 * parseInt(this.carousel.itemWidth)) + 
                    (2 * parseInt(this.carousel.midWidth)) + 
                    parseInt(this.carousel.centerWidth) + 
                    ((items.length-1) * margin) +
                    'px';
        expect(this.carousel.container.getStyle('width')).to(equal, width);
      });
      
      it("gets containerOffset", function() {
        expect(this.carousel.containerOffset()).to(be_zero);
        
        var result = parseInt(this.carousel.items[0].getStyle('margin-right')) + parseInt(this.carousel.itemWidth);
        this.carousel.next();
        
        expect(this.carousel.containerOffset()).to(equal, result);
      });
      
      it("redraws container", function() {
        expect(this.carousel.wrapper.getStyle('margin-left')).to(equal, '0px');
        
        this.carousel.currentIndex = 1;
        this.carousel.redraw();
        
        var margin = parseInt(this.carousel.items[0].getStyle('margin-right'));
        var result = parseInt(this.carousel.itemWidth + margin) * -1 + 'px'
        
        using(jQuery(this)).wait(.7).and_then(function() {
          expect(this.carousel.wrapper.getStyle('margin-left')).to(equal, result);
        });
      });
    });
    
    describe("element scaling", function() {
      before(function() {
        this.activeSet = this.carousel.activeSet();
        this.oldCenter = activeSet[3];
        this.newCenter = activeSet[2];
        this.toShrinkToNormal = activeSet[4];
        this.toGrowToMid = activeSet[1];
        this.oldCenter.setStyle({ height: '80px', width: '120px' });
        this.carousel.scale(1, { duration: .1 });
      });
      
      it("scales old center to mid dimensions", function() {
        using(jQuery(this)).wait(1).and_then(function() {
          expect(oldCenter.getStyle('height')).to(equal, this.carousel.midHeight);
          expect(oldCenter.getStyle('width')).to(equal, this.carousel.midWidth);
        });
      });
      
      it("scales new mid to mid dimensions", function() {
        using(jQuery(this)).wait(1).and_then(function() {
          expect(toGrowToMid.getStyle('height')).to(equal, this.carousel.midHeight);
          expect(toGrowToMid.getStyle('width')).to(equal, this.carousel.midWidth);
        });
      });
      
      it("scales new center to center dimensions", function() {
        using(jQuery(this)).wait(1).and_then(function() {
          expect(newCenter.getStyle('height')).to(equal, this.carousel.centerHeight);
          expect(newCenter.getStyle('width')).to(equal, this.carousel.centerWidth);
        });
      });
      
      it("scales old mid to normal item dimensions", function() {
        using(jQuery(this)).wait(1).and_then(function() {
          expect(toShrinkToNormal.getStyle('height')).to(equal, this.carousel.itemHeight);
          expect(toShrinkToNormal.getStyle('width')).to(equal, this.carousel.itemWidth);
        });
      });
      
      after(function() {
        $w('activeSet oldCenter newCenter toShrinkToNormal toGrowToMid').each(function(o) { delete(this[o]); });
      });
    });
    
    after(function() {
      delete(this.carousel);
      NEXT_LINK.stopObserving();
      PREV_LINK.stopObserving();
    })
  });
});