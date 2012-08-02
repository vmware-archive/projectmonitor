require 'openid'
require 'openid/extensions/ax'
require 'openid/store/filesystem'
require 'gapps_openid'

module OpenID
  def self.discover(uri)
    GoogleDiscovery.new.perform_discovery(uri)
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

    parameters = params.reject { |k, v| k == 'action' || k == 'controller'}
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
      redirect_to edit_configuration_path
    end
  end

  private

  def get_openid_consumer
    @openid_consumer ||= OpenID::Consumer.new(session, OpenID::Store::Filesystem.new("#{Rails.root}/tmp/openid"))
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
