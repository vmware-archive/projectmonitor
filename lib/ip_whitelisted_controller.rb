require 'ipaddr'

module IPWhitelistedController
  include ActiveSupport::Concern

  def self.included(base)
    return unless ConfigHelper.get(:ip_whitelist)

    base.before_filter :restrict_ip_address
    base.before_filter :authenticate_user!
  end

  private

  def restrict_access!
    authenticate_user!
  end

  def restrict_ip_address
    client_ip_address_str = if ConfigHelper.get(:ip_whitelist_request_proxied)
        (request.env['HTTP_X_FORWARDED_FOR'] || '').split(',').first.try(:strip)
      else
        request.env['REMOTE_ADDR']
      end

    client_ip_address = client_ip_address_str ? IPAddr.new(client_ip_address_str) : nil
    allowed_ips = ConfigHelper.get(:ip_whitelist).map { |ip_str| IPAddr.new(ip_str) }
    restrict_access! unless allowed_ips.any? { |ip| ip.include? client_ip_address }
  end
end
