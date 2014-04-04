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
    restrict_access! unless client_ip_in_whitelist(client_ip)
  end

  def client_ip_in_whitelist(ip)
    ip_whitelist.any? { |address| address.include? ip }
  end

  def client_ip
    client_ip_address_str = if ConfigHelper.get(:ip_whitelist_request_proxied)
        request.remote_ip
      else
        request.env['REMOTE_ADDR']
      end

    client_ip_address_str ? IPAddr.new(client_ip_address_str) : nil
  end

  def ip_whitelist
    ConfigHelper.get(:ip_whitelist).map { |ip_str| IPAddr.new(ip_str) }
  end
end
