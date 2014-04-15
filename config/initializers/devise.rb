require 'openid/store/filesystem'

Devise.setup do |config|
  require 'devise/orm/active_record'
  config.authentication_keys = [:login]
  config.case_insensitive_keys = [:login]
  config.strip_whitespace_keys = [:login]
  config.skip_session_storage = [:http_auth]

  ConfigHelper.get(:devise_encryptor) {|v| config.encryptor = v}
  config.pepper = ConfigHelper.get(:password_auth_pepper)
  config.stretches = ConfigHelper.get(:password_auth_stretches)
  config.sign_out_via = :delete

  config.reconfirmable = true
  config.reset_password_within = 6.hours

  if ConfigHelper.get(:password_auth_enabled)
    config.params_authenticatable = [:database]
  else
    config.params_authenticatable = false
  end

  if ConfigHelper.get(:oauth2_enabled)
    options = {access_type: 'offline', approval_prompt: ''}
    if ENV['HEROKU']
      heroku_cert_path = '/usr/lib/ssl/certs/ca-certificates.crt'
      options[:scope] = 'userinfo.profile,userinfo.email'
      options[:client_options] = {ssl: {ca_path: heroku_cert_path}}
    else
      ConfigHelper.get(:client_options) {|v| options[:client_options] = v}
    end
    ConfigHelper.get(:restrict_to_domain) {|v| options[:hd] = v}
    config.omniauth :google_oauth2, ConfigHelper.get(:oauth2_apphost), ConfigHelper.get(:oauth2_secret), options
    config.omniauth :github, ConfigHelper.get(:GITHUB_KEY), ConfigHelper.get(:GITHUB_SECRET), {scope: "user,repo"}
    config.omniauth :openid, :store => OpenID::Store::Filesystem.new('/tmp')
  end
end
