var TagSwitcher = (function () {
  var $tagSwitcher, pollIntervalSeconds = 30, timeoutFunction;

  return {
    init: function () {
      $tagSwitcher = $('select#tag');

      if ($tagSwitcher) {
        $tagSwitcher.val($('#current_tag').val());
        $tagSwitcher.change(TagSwitcher.switchTags);
      }
    },

    switchTags: function () {
      var tag = $(this).val();
      var destination = tag === '' ? '' : "?tags=" + tag;
      TagSwitcher.doRedirect(destination);
    },

    doRedirect: function (href) {
      var new_location = window.location.protocol + "//" + window.location.host + window.location.pathname + href;
      window.location.href = new_location;
    }
  };
})();
