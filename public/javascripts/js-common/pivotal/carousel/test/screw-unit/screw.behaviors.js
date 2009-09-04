Screw.Defaults = Screw.Defaults || {};
Screw.Defaults.to_run = 'body > .describe > .describes > .describe';

(function($) {
  $(Screw).bind('loaded', function() {
    $('.status').fn({
      display: function() {
        $(this).text(
          $('.it.passed' ).length + $('.failed').length + $('.skipped').length + ' finished, ' +
          $('.it.failed' ).length + ' failure(s), ' + 
          $('.it.skipped').length + ' skipped, ' + 
          $('.it.async'  ).length + ' running asynchronous test(s)'
        );
      }
    });

    $('.describe').fn({
      parent: function() {
        return $(this).parent('.describes').parent('.describe');
      },
      
      run_befores: function() {
        $(this).fn('parent').fn('run_befores');
        $(this).children('.befores').children('.before').fn('run');
      },
      
      run_afters: function() {
        $(this).fn('parent').fn('run_afters');
        $(this).children('.afters').children('.after').fn('run');
      },
      
      enqueue: function() {
        $(this).children('.its').children('.it').fn('enqueue');
        $(this).children('.describes').children('.describe').fn('enqueue');
      },
      
      selector: function() {
        return $(this).fn('parent').fn('selector')
          + ' > .describes > .describe:eq(' + $(this).parent('.describes').children('.describe').index(this) + ')';
      }
    });
  
    $('body > .describe').fn({
      selector: function() { return 'body > .describe' }
    });
    
    $('.it').fn({
      parent: function() {
        return $(this).parent('.its').parent('.describe');
      },
      
      run: function() {
        if ($(this).hasClass('skipped')){return}
        
        try {
          try {
            $(this).fn('parent').fn('run_befores');
            $(this).data('screwunit.run')($(this));
          } finally {
            $(this).fn('parent').fn('run_afters');
          }
          $(this).trigger('passed');
        } catch(e) {
          $(this).trigger('failed', [e]);
        }
      },
      
      enqueue: function() {
        var self = $(this).trigger('enqueued');
        $(Screw)
          .queue(function() {
            self.fn('run');
            setTimeout(function() { $(Screw).dequeue() }, 0);
          });
      },
      
      selector: function() {
        return $(this).fn('parent').fn('selector')
          + ' > .its > .it:eq(' + $(this).parent('.its').children('.it').index(this) + ')';
      }
    });
    
    $('.before').fn({
      run: function() { $(this).data('screwunit.run')($(this)) }
    }); 
  
    $('.after').fn({
      run: function() { $(this).data('screwunit.run')($(this)) }
    });

    $(Screw).trigger('before');
    var to_run = unescape(location.search.slice(1)) || Screw.Defaults.to_run;
    $(to_run)
      .focus()
      .eq(0).trigger('scroll').end()
      .fn('enqueue');
    $(Screw).queue(function() { $(Screw).trigger('after') });
  })
})(jQuery);
