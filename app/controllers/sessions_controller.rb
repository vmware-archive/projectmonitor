class SessionsController < Devise::SessionsController

  # Handle the case where legacy passwords are stored for a user attempting to
  # authenticate
  def create
    super
  rescue BCrypt::Errors::InvalidHash
    flash[:error] = "The system has been upgraded, your password needs to be reset before logging in."
    redirect_to new_user_password_path
  end

  def new
    if ConfigHelper.get(:password_auth_enabled)
      super
    else
      redirect_to user_omniauth_authorize_url(:google_oauth2)
    end
  end

end
