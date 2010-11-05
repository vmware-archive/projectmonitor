require 'openid'
require 'openid/extensions/ax'
require 'openid/store/filesystem'

# todo - cleanup with tests - pulled from omniauth...

require 'gapps_openid'

module OpenID
  # Because gapps_openid changes the discovery order
  # (looking first for Google Apps, then anything else),
  # we need to monkeypatch it to make it play nicely
  # with others.
  def self.discover(uri)
    discovered = self.default_discover(uri)

    if discovered.last.empty?
      info = discover_google_apps(uri)
      return info if info
    end

    return discovered
  rescue OpenID::DiscoveryFailure => e
    info = discover_google_apps(uri)

    if info.nil?
      raise e
    else
      return info
    end
  end

  def self.discover_google_apps(uri)
    discovery = GoogleDiscovery.new
    discovery.perform_discovery(uri)
  end
end

class OpenidsController < ApplicationController

  def new
    logout_keeping_session!
    checkid_request = get_openid_consumer.begin(AuthConfig.openid_identifier)
    redirect_url = checkid_request.redirect_url(AuthConfig.openid_realm, AuthConfig.openid_return_to)
    extended_url = append_ax(redirect_url)
    redirect_to(extended_url)
  end

  def success
    if params["openid.mode"] == "cancel"
      redirect_to(root_path)
      return
    end

    parameters = params.reject { |k, v| request.path_parameters[k] }
    current_url = url_for(:action => 'success', :only_path => false)
    consumer_response = get_openid_consumer.complete(parameters, current_url)

    fetch_response = OpenID::AX::FetchResponse.from_success_response(consumer_response)
    user = User.find_or_create_from_google_openid(fetch_response)

    self.current_user = user
    if user.errors.count > 0
      flash[:notice] = user.errors.full_messages
      redirect_to login_path
    else
      flash[:notice] = "Logged in successfully"
      redirect_to root_path
    end
  end

  private

  def get_openid_consumer
    @openid_consumer ||= OpenID::Consumer.new(session, OpenID::Store::Filesystem.new("#{RAILS_ROOT}/tmp/openid"))
  end

  def append_ax(redirect_url)
    ax = %w{
        openid.ns.ext1=http://openid.net/srv/ax/1.0
        openid.ext1.mode=fetch_request
        openid.ext1.type.email=http://axschema.org/contact/email
        openid.ext1.type.firstName=http://axschema.org/namePerson/first,
        openid.ext1.type.lastName=http://axschema.org/namePerson/last,
        openid.ext1.required=email,firstName,lastName
      }.join("&")
    "#{redirect_url}&#{ax}"
  end

end