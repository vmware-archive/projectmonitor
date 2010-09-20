require 'oauth/consumer'
require 'oauth/signature/rsa/sha1'

class OauthsController < ApplicationController

  skip_before_filter :auth_required?, :only => [:new, :success]

  def new
    logout_keeping_session!
    request_token = get_oauth_consumer.get_request_token({:oauth_callback => success_oauth_url},
                                                         {:scope => AuthConfig.oauth.scope})
    session[:oauth_secret] = request_token.secret
    redirect_to(request_token.authorize_url)
  end

  def success
    request_token = OAuth::RequestToken.new(get_oauth_consumer, params[:oauth_token], session[:oauth_secret])    
    access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
    user = User.find_or_create_from_google_access_token(access_token)
    self.current_user = user
    redirect_to root_path
    flash[:notice] = "Logged in successfully"
  end

  private

  def get_oauth_consumer
    OAuth::Consumer.new(AuthConfig.oauth.consumer_key, AuthConfig.oauth.consumer_secret,
                        {
                                :site => AuthConfig.oauth.site,
                                :request_token_path => AuthConfig.oauth.request_token_path,
                                :access_token_path => AuthConfig.oauth.access_token_path,
                                :authorize_path=> AuthConfig.oauth.authorize_path,
                                :signature_method => AuthConfig.oauth.signature_method})
  end
end