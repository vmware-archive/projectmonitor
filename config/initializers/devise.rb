Devise.setup do |config|
  config.mailer_sender = Rails.configuration.mailer_sender
  require 'devise/orm/active_record'
  config.authentication_keys = [:login]
  config.case_insensitive_keys = [:login]
  config.strip_whitespace_keys = [:login]
  config.skip_session_storage = [:http_auth]

  config_for(:devise_encryptor) {|v| config.encryptor = v}
  config.pepper = config_for(:password_auth_pepper)
  config.stretches = config_for(:password_auth_stretches)
  config.sign_out_via = :delete

  config.reconfirmable = true
  config.reset_password_within = 6.hours

  if config_for(:password_auth_enabled)
    config.params_authenticatable = [:database]
  else
    config.params_authenticatable = false
  end

  if config_for(:oauth2_enabled)
    options = {access_type: 'offline', approval_prompt: ''}
    if ENV['HEROKU']
      heroku_cert_path = '/usr/lib/ssl/certs/ca-certificates.crt'
      options[:scope] = 'userinfo.profile,userinfo.email'
      options[:client_options] = {ssl: {ca_path: heroku_cert_path}}
    else
      config_for(:client_options) {|v| options[:client_options] = v}
    end
    config_for(:restrict_to_domain) {|v| options[:hd] = v}
    config.omniauth :google_oauth2, config_for(:oauth2_apphost), config_for(:oauth2_secret), options
  end
end
