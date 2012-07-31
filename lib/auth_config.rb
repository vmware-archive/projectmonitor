module AuthConfig
  class << self

    def load_from(path)
      config = File.exist?(path) ? YAML.load_file(path) : {}
      config[Rails.env] || {}
    end

    def load_auth_config
      load_from(auth_file_path)
    end

    def auth_file_path
      Rails.root.join("config/auth.yml")
    end

    def auth_config
      @auth_config ||= load_auth_config
    end

    def openid?
      auth_strategy == "openid"
    end

    def password?
      auth_strategy == "password"
    end

    def auth_strategy
      ENV['AUTH_STRATEGY'] || auth_config['auth_strategy']
    end

    def rest_auth_site_key
      ENV['REST_AUTH_SITE_KEY'] || auth_config['rest_auth_site_key']
    end

    def rest_auth_digest_stretches
      s = ENV['REST_AUTH_DIGEST_STRETCHES'] || auth_config['rest_auth_digest_stretches']
      s && s.to_i
    end

    def openid_identifier
      ENV['OPENID_IDENTIFIER'] || auth_config['openid_identifier']
    end

    def openid_realm
      ENV['OPENID_REALM'] || auth_config['openid_realm']
    end

    def openid_return_to
      ENV['OPENID_RETURN_TO'] || auth_config['openid_return_to']
    end

    # for testing
    def reset!
      @auth_config = nil
    end

  end
end
