ProjectMonitor::Application.configure do
  config.cache_classes = false

  config.eager_load = false

  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.active_support.deprecation = :log

  config.assets.debug = true

  config.sass.debug_info = true
  config.sass.line_comments = false

  config.active_record.migration_error = :page_load

  config.action_mailer.raise_delivery_errors = false
end
