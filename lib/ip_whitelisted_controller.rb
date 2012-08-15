module IPWhitelistedController
  include ActiveSupport::Concern

  def self.included(base)
    return unless ConfigHelper.get(:ip_whitelist)

    base.before_filter :restrict_ip_address
    base.before_filter :authenticate_user!
  end

  private

  def restrict_ip_address
    client_ip_address = if ConfigHelper.get(:ip_whitelist_request_proxied)
        (request.env['HTTP_X_FORWARDED_FOR'] || '').split(',').first.try(:strip)
      else
        request.env['REMOTE_ADDR']
      end

    head 403 unless ConfigHelper.get(:ip_whitelist).include?(client_ip_address)
  end

end
