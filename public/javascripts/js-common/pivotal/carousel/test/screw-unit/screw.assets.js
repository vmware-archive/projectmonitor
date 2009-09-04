(function() {
  Screw.Assets = {};
  Screw.Assets.use_cache_buster = false; // TODO: NS/CTI - make this configurable from the UI.
  var required_paths = [];
  var included_stylesheets = {};
  var cache_buster = parseInt(new Date().getTime()/(1*1000));

  Screw.Assets.require = function(javascript_path, onload) {
    if(!required_paths[javascript_path]) {
      var full_path = javascript_path + ".js";
      if (Screw.Assets.use_cache_buster) {
        full_path += '?' + cache_buster;
      }
      document.write("<script src='" + full_path + "' type='text/javascript'></script>");
      if(onload) {
        var scripts = document.getElementsByTagName('script');
        scripts[scripts.length-1].onload = onload;
      }
      required_paths[javascript_path] = true;
    }
  };

  Screw.Assets.stylesheet = function(stylesheet_path) {
    if(!included_stylesheets[stylesheet_path]) {
      var full_path = stylesheet_path + ".css";
      if(Screw.Assets.use_cache_buster) {
        full_path += '?' + cache_buster;
      }
      document.write("<link rel='stylesheet' type='text/css' href='" + full_path + "' />");
      included_stylesheets[stylesheet_path] = true;
    }
  };

  window.require = Screw.Assets.require;
  window.stylesheet = Screw.Assets.stylesheet;
})();
