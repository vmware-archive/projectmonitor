//= require_self
//= require_tree ./templates
//= require_tree ./models
//= require_tree ./collections
//= require_tree ./views
//= require_tree ./routers

window.ProjectMonitor = {
  Models: {},
  Collections: {},
  Routers: {},
  Views: {},
  Window: {
    reload: function () {
      return window.location.reload();
    }
  }
};
