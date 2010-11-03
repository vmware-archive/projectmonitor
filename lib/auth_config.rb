class AuthConfig
  def self.load_from(path)
    config = File.exist?(path) ? YAML.load_file(path) : {}
    config[Rails.env] || {}
  end

  def self.load_auth_config
    self.load_from(auth_file_path)
  end

  def self.auth_file_path
    Rails.root.join("config/auth.yml")
  end

  def self.auth_config
    @auth_config ||= self.load_auth_config
  end

  def self.auth_required
    if ENV['AUTH_REQUIRED'].nil?
      auth_config['auth_required']
    else
      ENV['AUTH_REQUIRED']
    end
  end

  def self.rest_auth_site_key
    ENV['REST_AUTH_SITE_KEY'] || auth_config['rest_auth_site_key']
  end

  def self.rest_auth_digest_stretches
    s = ENV['REST_AUTH_DIGEST_STRETCHES'] || auth_config['rest_auth_digest_stretches']
    s && s.to_i
  end

  def self.openid_identifier
    ENV['OPENID_IDENTIFIER'] || auth_config['openid_identifier']
  end

  def self.openid_realm
    ENV['OPENID_REALM'] || auth_config['openid_realm']
  end

  def self.openid_return_to
    ENV['OPENID_RETURN_TO'] || auth_config['openid_return_to']
  end

  # for testing
  def self.reset!
    @auth_config = nil
  end
end
