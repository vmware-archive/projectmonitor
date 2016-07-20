require_relative 'boot'

require 'rails/all'

Bundler.require(:default, Rails.env)

require 'tilt/coffee'

module ProjectMonitor
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.from_file 'settings.yml'
    config.autoload_paths += %W(#{config.root}/lib #{config.root}/lib/payload)
    config.encoding = 'utf-8'

    config.action_mailer.default_url_options = Rails.configuration.emailer_host.to_hash.symbolize_keys
    config.secret_key_base = 'project_monitor'

    config.cache_store = :memory_store
  end
end
