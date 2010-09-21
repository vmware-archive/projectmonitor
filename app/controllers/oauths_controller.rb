require 'oauth/consumer'
require 'oauth/signature/rsa/sha1'

class OauthsController < ApplicationController

  skip_before_filter :auth_required?, :only => [:new, :success]

  def new
    logout_keeping_session!
    request_token = get_oauth_consumer.get_request_token({:oauth_callback => success_oauth_url},
                                                         {:scope => AuthConfig.scope})
    session[:oauth_secret] = request_token.secret
    redirect_to(request_token.authorize_url)
  end

  def success
    request_token = OAuth::RequestToken.new(get_oauth_consumer, params[:oauth_token], session[:oauth_secret])    
    access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
    user = User.find_or_create_from_google_access_token(access_token)
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

  def get_oauth_consumer
    OAuth::Consumer.new(AuthConfig.consumer_key, AuthConfig.consumer_secret,
                        {
                                :site => AuthConfig.site,
                                :request_token_path => AuthConfig.request_token_path,
                                :access_token_path => AuthConfig.access_token_path,
                                :authorize_path=> AuthConfig.authorize_path,
                                :signature_method => AuthConfig.signature_method})
  end
end