require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env)

module ProjectMonitor
  class Application < Rails::Application
    config.from_file 'settings.yml'
    config.autoload_paths += %W(#{config.root}/lib #{config.root}/lib/payload)
    config.encoding = 'utf-8'
    config.i18n.fallbacks = true

    config.serve_static_assets = true

    config.assets.compile = true
    config.assets.enabled = true
    config.assets.version = '1.1'
    config.assets.initialize_on_precompile = false
    config.assets.paths << Rails.root.join('app','assets','skins')

    config.action_mailer.default_url_options = Rails.configuration.emailer_host.to_hash.symbolize_keys
    config.secret_key_base = 'project_monitor'

    config.cache_store = :memory_store
    config.static_cache_control = "public, max-age=3600"
  end
end
