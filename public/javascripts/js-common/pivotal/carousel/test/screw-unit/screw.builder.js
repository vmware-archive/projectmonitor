var Screw = (function($) {
  var screw = {
    Unit: function(fn) {
      var contents = fn.toString().match(/^[^\{]*{((.*\n*)*)}/m)[1];
      var fn = new Function("matchers", "specifications", "utilities",
        "with (specifications) { with (matchers) { with (utilities) {" + contents + " } } }"
      );

      $(Screw).queue(function() {
        Screw.Specifications.context.push($('body > .describe'));
        fn.call(this, Screw.Matchers, Screw.Specifications, Screw.Utilities);
        Screw.Specifications.context.pop();
        $(this).dequeue();
      });
    },

    Utilities: {
      /*
       * 'me' is $(this) being passed to the screwunit.run function (see screw.behaviors.js)
       *   $(this).data('screwunit.run')($(this));
       */
       
      skip: function(me){
        return {
          because: function(reason) {
            me.trigger('skipped', [reason]);
            throw '';
          }
        }
      },
      
      using: function( me ) {
        return {
          wait : function( seconds ) {
            return {
              and_then: function( fn ) {
                var f = function() {
                  var async_count = me.data('async_waiting_count') - 1;
                  me.data('async_waiting_count', async_count);
                  if (async_count < 1) {
                    me.removeClass('async');
                  }

                  try {
                    fn(me);
                  } catch (e) {
                    me.trigger('failed', [e]);
                    return;
                  }
                  me.trigger('passed');
                };

                var async_count = me.data('async_waiting_count') ||  0
                me.data('async_waiting_count', async_count + 1)

                me.addClass('async');

                // allow the "it" we are called from to finish, which will add class "passed", which we want to remove.
                setTimeout(function(){ me.trigger('running'); }, 2);

                setTimeout(f, 1000 * parseInt(seconds,10));
              } 
            }
          }
        }  
      }
    },

    Specifications: {
      context: [],

      describe: function(name, fn) {
        var describe = $('<li class="describe"></li>')
          .append($('<h1></h1>').text(name))
          .append('<ol class="befores"></ol>')
          .append('<ul class="its"></ul>')
          .append('<ul class="describes"></ul>')
          .append('<ol class="afters"></ol>');

        this.context.push(describe);
        fn.call();
        this.context.pop();

        this.context[this.context.length-1]
          .children('.describes')
            .append(describe);
      },

      it: function(name, fn) {
        var it = $('<li class="it"></li>')
          .append($('<h2></h2>').text(name))
          .data('screwunit.run', fn);

        this.context[this.context.length-1]
          .children('.its')
            .append(it);
      },

      before: function(fn) {
        var before = $('<li class="before"></li>')
          .data('screwunit.run', fn);

        this.context[this.context.length-1]
          .children('.befores')
            .append(before);
      },

      after: function(fn) {
        var after = $('<li class="after"></li>')
          .data('screwunit.run', fn);

        this.context[this.context.length-1]
          .children('.afters')
            .append(after);
      }
    }
  };

  $(screw).queue(function() { $(screw).trigger('loading') });
  $(function() {
    $('<div class="describe"></div>')
      .append('<h3 class="status"></h3>')
      .append('<ol class="befores"></ol>')
      .append('<ul class="describes"></ul>')
      .append('<ol class="afters"></ol>')
      .appendTo('body');

    $(screw).dequeue();
    $(screw).trigger('loaded');
  });
  return screw;
})(jQuery);