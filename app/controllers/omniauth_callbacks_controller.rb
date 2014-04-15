class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user)

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: "Google"
      sign_in_and_redirect @user, event: :authentication
    else
      session["devise.google_data"] = request.env["omniauth.auth"]
      redirect_to edit_configuration_url
    end
  end

  def github
    github_token = request.env["omniauth.auth"].credentials.token
    travis_pro_token = Travis::Pro.github_auth(github_token)
    current_user.github_token = github_token
    current_user.travis_pro_token = travis_pro_token
    current_user.save
    redirect_to "/projects/new"
  end
end
