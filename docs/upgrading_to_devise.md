# Upgrading

ProjectMonitor has recently moved to
[Devise](https://github.com/plataformatec/devise/) for authentication. This
means that any existing users will have invalid passwords. If you don't want
all your users to have to reset their passwords, you can alter the following
configuration settings to support legacy passwords:

    devise_encryptor: :legacy
    devise_pepper: <rest_auth_site_key>
    devise_stretches: <rest_auth_digest_stretches>

The values for `rest_auth_site_key` and `rest_auth_digest_stretches` can be found
in your `config/auth.yml`. This file is no longer needed.
