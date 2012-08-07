class UsersController < ApplicationController
  before_filter :authenticate_user!

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to(root_path)
      flash[:notice] = "User created."
    else
      render :new
    end
  end
end
