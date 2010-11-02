class AuthConfig

  SETTINGS = %w[rest_auth_site_key rest_auth_digest_stretches openid_identifier openid_realm openid_return_to]

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

  def self.method_missing(method, *args, &block)
    m = method.to_s
    if SETTINGS.include?(m)
      ENV[m.upcase] || auth_config[m]
    else
      super
    end
  end

  def self.respond_to?(method, *args)
    SETTINGS.include?(method.to_s) || super
  end

  # for testing
  def self.reset!
    @auth_config = nil
  end

end
