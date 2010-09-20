require 'oauth/consumer'
require 'oauth/signature/rsa/sha1'

class OauthsController < ApplicationController
  def new
    request_token = get_oauth_consumer.get_request_token({:oauth_callback => success_oauth_url},
                                                         {:scope => GoogleOAuthConfig.scope})
    session[:oauth_secret] = request_token.secret
    redirect_to(request_token.authorize_url)
  end

  def success
    request_token = OAuth::RequestToken.new(get_oauth_consumer, params[:oauth_token], session[:oauth_secret])
    access_token = request_token.get_access_token
    user = User.find_or_create_from_google_access_token(access_token)
    self.current_user = user
    redirect_to root_path
    flash[:notice] = "Logged in successfully"
  end

  private

  def get_oauth
    OAuth::Consumer.new(GoogleOAuthConfig.consumer_key, GoogleOAuthConfig.consumer_secret,
                        {
                                :site => GoogleOAuthConfig.site,
                                :request_token_path => GoogleOAuthConfig.request_token_path,
                                :access_token_path => GoogleOAuthConfig.access_token_path,
                                :authorize_path=> GoogleOAuthConfig.authorize_path,
                                :signature_method => GoogleOAuthConfig.signature_method})
  end
end