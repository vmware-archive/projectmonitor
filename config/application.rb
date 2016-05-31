require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env)

require 'tilt/coffee'

module ProjectMonitor
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.from_file 'settings.yml'
    config.autoload_paths += %W(#{config.root}/lib #{config.root}/lib/payload)
    config.encoding = 'utf-8'

    config.action_mailer.default_url_options = Rails.configuration.emailer_host.to_hash.symbolize_keys
    config.secret_key_base = 'project_monitor'

    config.cache_store = :memory_store
    config.static_cache_control = "public, max-age=3600"
  end
end
