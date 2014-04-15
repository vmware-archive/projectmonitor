class TokensController < ApplicationController

  def destroy
    if params[:provider] == "github"
      current_user.update(github_token: nil, travis_pro_token: nil)
      flash[:notice] = "Successfully unlinked Github and Travis Pro"
      redirect_to edit_configuration_path
    else
      render text: "public/404.html", status: 404
    end
  end
end