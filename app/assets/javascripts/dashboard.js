//= require application
//= require refresh
//= require twitter
//= require versionCheck
//= require projectCheck
//= require spin

$(function() {
  VersionCheck.init();
  ProjectCheck.init();

  $('.building-indicator').spin({radius:8, length:6, width:3, lines:12, top:6, left:8});
});

$.fn.spin = function(opts) {
  this.each(function() {
    var $this = $(this),
        data = $this.data();

    if (data.spinner) {
      data.spinner.stop();
      delete data.spinner;
    }
    if (opts !== false) {
      data.spinner = new Spinner($.extend({color: $this.css('color')}, opts)).spin(this);
    }
  });
  return this;
};
