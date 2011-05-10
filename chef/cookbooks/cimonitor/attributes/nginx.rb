node["nginx_settings"] ||= {}
node["nginx_settings"]["basic_auth_users"] = CI_CONFIG['basic_auth']