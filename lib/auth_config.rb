class AuthConfig

  # todo - there might be a better pattern here....
  
  def self.load_from(path)
    config = {}
    config = YAML.load_file(path) if File.exist?(path)
    @@auth_config = {}
    @@auth_config.update(config[ENV['RAILS_ENV']] || {})
  end

  self.load_from("#{Rails.root}/config/auth.yml")

  def self.auth_required
    (ENV['auth_required'] == 'true') || @@auth_config['auth_required']
  end

  def self.openid_identifier
    ENV['openid_identifier'] || @@auth_config['openid_identifier']
  end

  def self.openid_realm
    ENV['openid_realm'] || @@auth_config['openid_realm']
  end

  def self.openid_return_to
    ENV['openid_return_to'] || @@auth_config['openid_return_to']
  end

end