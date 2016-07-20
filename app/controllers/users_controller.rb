class UsersController < ApplicationController
  before_action :authenticate_user!

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to(root_path)
      flash[:notice] = 'User created.'
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:login, :email, :password, :password_confirmation)
  end
end
