class AuthConfig
  config = YAML.load_file("#{Rails.root}/config/auth.yml") || {}
  auth_config = {}
  auth_config.update(config[ENV['RAILS_ENV']] || {})

  auth_config.each do |attrib, value|
    cattr_reader(attrib)
    class_variable_set("@@#{attrib}", value)
  end
end